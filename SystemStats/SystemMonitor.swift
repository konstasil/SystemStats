import Foundation
import Combine
import IOKit
import IOKit.ps

final class SystemMonitor: ObservableObject {
    @Published var cpuUsage: Double = 0
    @Published var memoryUsage: Double = 0
    @Published var memoryUsedGB: Double = 0
    @Published var memoryTotalGB: Double = 0
    @Published var gpuTemperature: Double = 0
    @Published var cpuHistory: [Double] = []
    @Published var memoryHistory: [Double] = []

    private var timer: Timer?
    private let historyCapacity = 60
    var isRunning = false

    func start() {
        guard !isRunning else { return }
        isRunning = true
        updateStats()
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateStats()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    private func updateStats() {
        let cpu = readCPUUsage()
        let mem = readMemoryUsage()
        let gpu = readGPUTemperature()

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.cpuUsage = cpu
            self.memoryUsage = mem.usedPercent
            self.memoryUsedGB = mem.usedGB
            self.memoryTotalGB = mem.totalGB
            self.gpuTemperature = gpu

            self.cpuHistory.append(cpu)
            if self.cpuHistory.count > self.historyCapacity {
                self.cpuHistory.removeFirst()
            }

            self.memoryHistory.append(mem.usedPercent)
            if self.memoryHistory.count > self.historyCapacity {
                self.memoryHistory.removeFirst()
            }
        }
    }

    private func readCPUUsage() -> Double {
        var threadList: UnsafeMutablePointer<thread_t>?
        var threadCount: mach_msg_type_number_t = 0

        let result = task_threads(mach_task_self_, &threadList, &threadCount)
        guard result == KERN_SUCCESS, let threads = threadList else {
            return 0
        }

        var totalUsage: Double = 0
        let count = Int(threadCount)
        let infoCountValue = MemoryLayout<thread_basic_info_data_t>.size / MemoryLayout<integer_t>.size

        for i in 0..<count {
            let thread = threads[i]
            var info = thread_basic_info()
            var infoCount = mach_msg_type_number_t(infoCountValue)

            let kr = withUnsafeMutablePointer(to: &info) { infoPtr in
                infoPtr.withMemoryRebound(to: integer_t.self, capacity: infoCountValue) { intPtr in
                    thread_info(thread, thread_flavor_t(THREAD_BASIC_INFO), intPtr, &infoCount)
                }
            }

            if kr == KERN_SUCCESS && (info.flags & TH_FLAGS_IDLE) == 0 {
                totalUsage += Double(info.cpu_usage) / Double(TH_USAGE_SCALE)
            }
        }

        for i in 0..<count {
            mach_port_deallocate(mach_task_self_, threads[i])
        }

        vm_deallocate(mach_task_self_, vm_address_t(bitPattern: threadList), vm_size_t(count * MemoryLayout<thread_t>.size))

        return min(totalUsage * 100.0, 100.0)
    }

    private func readMemoryUsage() -> (usedPercent: Double, usedGB: Double, totalGB: Double) {
        var physicalMemory: UInt64 = 0
        var physSize = MemoryLayout<UInt64>.size
        sysctlbyname("hw.memsize", &physicalMemory, &physSize, nil, 0)

        let totalGB = Double(physicalMemory) / (1024 * 1024 * 1024)

        var stats = vm_statistics64()
        var size = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)

        let result = withUnsafeMutablePointer(to: &stats) { ptr in
            ptr.withMemoryRebound(to: integer_t.self, capacity: Int(size)) { intPtr in
                host_statistics64(mach_host_self(), HOST_VM_INFO64, intPtr, &size)
            }
        }

        guard result == KERN_SUCCESS else {
            return (0, 0, totalGB)
        }

        let free = Double(stats.free_count)
        let inactive = Double(stats.inactive_count)
        let speculative = Double(stats.speculative_count)

        let availablePages = free + inactive + speculative

        var pageSize: vm_size_t = 0
        host_page_size(mach_host_self(), &pageSize)

        let availableGB = (availablePages * Double(pageSize)) / (1024 * 1024 * 1024)
        let usedGB = totalGB - availableGB
        let percent = totalGB > 0 ? (usedGB / totalGB) * 100.0 : 0

        return (percent, usedGB, totalGB)
    }

    private func readGPUTemperature() -> Double {
        var iterator: io_iterator_t = 0
        let matching = IOServiceMatching("AppleGPU")
        guard IOServiceGetMatchingServices(kIOMainPortDefault, matching, &iterator) == KERN_SUCCESS else {
            return readGPUTemperatureFallback()
        }

        var service = IOIteratorNext(iterator)
        while service != IO_OBJECT_NULL {
            var props: Unmanaged<CFMutableDictionary>?
            if IORegistryEntryCreateCFProperties(service, &props, kCFAllocatorDefault, IOOptionBits(kIORegistryIterateRecursively)) == kIOReturnSuccess {
                if let dict = props?.takeRetainedValue() as? [String: Any] {
                    if let temp = dict["temperature"] as? Double {
                        IOObjectRelease(service)
                        IOObjectRelease(iterator)
                        return temp / 65536.0
                    }
                    if let temp = dict["gpu-temperature"] as? Double {
                        IOObjectRelease(service)
                        IOObjectRelease(iterator)
                        return temp
                    }
                }
            }
            IOObjectRelease(service)
            service = IOIteratorNext(iterator)
        }
        IOObjectRelease(iterator)

        return readGPUTemperatureFallback()
    }

    private func readGPUTemperatureFallback() -> Double {
        var iterator: io_iterator_t = 0
        let matching = IOServiceMatching("IOHWSensor")
        guard IOServiceGetMatchingServices(kIOMainPortDefault, matching, &iterator) == KERN_SUCCESS else {
            return 0
        }

        var service = IOIteratorNext(iterator)
        while service != IO_OBJECT_NULL {
            var props: Unmanaged<CFMutableDictionary>?
            if IORegistryEntryCreateCFProperties(service, &props, kCFAllocatorDefault, IOOptionBits(kIORegistryIterateRecursively)) == kIOReturnSuccess {
                if let dict = props?.takeRetainedValue() as? [String: Any] {
                    if let name = dict["name"] as? String, name.lowercased().contains("gpu") {
                        if let temp = dict["CurrentTemperature"] as? Double {
                            IOObjectRelease(service)
                            IOObjectRelease(iterator)
                            return temp
                        }
                    }
                }
            }
            IOObjectRelease(service)
            service = IOIteratorNext(iterator)
        }
        IOObjectRelease(iterator)

        return 0
    }
}

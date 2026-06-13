import SwiftUI

struct PopoverView: View {
    @ObservedObject var monitor: SystemMonitor
    @AppStorage("showCPU") private var showCPU = true
    @AppStorage("showMemory") private var showMemory = true
    @AppStorage("showGPU") private var showGPU = true
    @AppStorage("displayMode") private var displayMode = "both"

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HeaderSection

            Divider()

            if showCPU {
                StatRow(
                    icon: "cpu",
                    title: NSLocalizedString("menu.cpu.title", comment: ""),
                    value: String(format: "%.1f%%", monitor.cpuUsage),
                    color: cpuColor,
                    history: monitor.cpuHistory
                )
            }

            if showMemory {
                StatRow(
                    icon: "memorychip",
                    title: NSLocalizedString("menu.memory.title", comment: ""),
                    value: String(format: "%.1f%%", monitor.memoryUsage),
                    color: memoryColor,
                    history: monitor.memoryHistory
                )
            }

            if showGPU {
                GPUTempRow
            }

            Divider()

            DisplayModeSection

            Divider()

            FooterSection
        }
        .padding(12)
        .frame(width: 260)
        .onAppear {
            monitor.start()
        }
    }

    private var HeaderSection: some View {
        HStack {
            Image(systemName: "chart.bar.fill")
                .foregroundStyle(.blue)
            Text(NSLocalizedString("app.title", comment: ""))
                .font(.headline)
            Spacer()
            Circle()
                .fill(monitor.isRunning ? .green : .red)
                .frame(width: 8, height: 8)
        }
    }

    private var GPUTempRow: some View {
        HStack {
            Image(systemName: "thermometer")
                .foregroundStyle(gpuTempColor)
                .frame(width: 16)
            Text(NSLocalizedString("menu.gpu.title", comment: ""))
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(String(format: "%.1f°C", monitor.gpuTemperature))
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(gpuTempColor)
        }
        .padding(.vertical, 4)
    }

    private var DisplayModeSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(NSLocalizedString("settings.display", comment: ""))
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 6) {
                ModeButton(icon: "chart.bar.fill", mode: "graph")
                ModeButton(icon: "percent", mode: "percent")
                ModeButton(icon: "chart.bar.doc.horizontal", mode: "both")
            }
        }
    }

    private var FooterSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Toggle(NSLocalizedString("settings.cpu", comment: ""), isOn: $showCPU)
                    .font(.caption)
                    .toggleStyle(.checkbox)

                Toggle(NSLocalizedString("settings.memory", comment: ""), isOn: $showMemory)
                    .font(.caption)
                    .toggleStyle(.checkbox)

                Toggle(NSLocalizedString("settings.gpu", comment: ""), isOn: $showGPU)
                    .font(.caption)
                    .toggleStyle(.checkbox)
            }

            HStack {
                Spacer()
                Button(NSLocalizedString("menu.quit", comment: "")) {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.red)
                .font(.caption)
            }
        }
    }

    private struct ModeButton: View {
        let icon: String
        let mode: String
        @AppStorage("displayMode") private var displayMode = "both"

        var body: some View {
            Button {
                displayMode = mode
            } label: {
                Image(systemName: icon)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(displayMode == mode ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(displayMode == mode ? .white : .primary)
                    .cornerRadius(6)
            }
            .buttonStyle(.plain)
        }
    }

    private var cpuColor: Color {
        if monitor.cpuUsage > 80 { return .red }
        if monitor.cpuUsage > 50 { return .orange }
        return .green
    }

    private var memoryColor: Color {
        if monitor.memoryUsage > 80 { return .red }
        if monitor.memoryUsage > 50 { return .orange }
        return .blue
    }

    private var gpuTempColor: Color {
        if monitor.gpuTemperature > 80 { return .red }
        if monitor.gpuTemperature > 60 { return .orange }
        return .green
    }
}

struct StatRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let history: [Double]

    @AppStorage("displayMode") private var displayMode = "both"

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 16)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 60, alignment: .leading)

            if displayMode == "graph" || displayMode == "both" {
                MiniGraphView(data: history, color: color, maxValue: 100, size: CGSize(width: 60, height: 16))
                    .frame(width: 60, height: 16)
            }

            Spacer()

            if displayMode == "percent" || displayMode == "both" {
                Text(value)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(color)
            }
        }
        .padding(.vertical, 2)
    }
}

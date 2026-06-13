import AppKit
import SwiftUI

class StatusBarController: NSObject {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var eventMonitor: Any?
    private var monitor: SystemMonitor

    init(monitor: SystemMonitor) {
        self.monitor = monitor
        super.init()

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            let statusView = StatusItemView(monitor: monitor)
            statusView.frame = button.bounds
            statusView.autoresizingMask = [.width, .height]
            button.addSubview(statusView)
            button.action = #selector(togglePopover(_:))
            button.target = self
        }

        popover = NSPopover()
        popover.contentSize = NSSize(width: 260, height: 320)
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSHostingController(rootView: PopoverView(monitor: monitor))

        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            if let popover = self?.popover, popover.isShown {
                self?.closePopover()
            }
        }
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            closePopover()
        } else {
            showPopover()
        }
    }

    func showPopover() {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    func closePopover() {
        popover.performClose(nil)
    }

    deinit {
        if let eventMonitor = eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
    }
}

class StatusItemView: NSView {
    var monitor: SystemMonitor
    private var timer: Timer?

    init(monitor: SystemMonitor) {
        self.monitor = monitor
        super.init(frame: NSRect(x: 0, y: 0, width: 50, height: 22))
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        wantsLayer = true
        layer?.cornerRadius = 4

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.redraw()
        }

        redraw()
    }

    override var fittingSize: NSSize {
        return NSSize(width: 50, height: 22)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let graphFrame = NSRect(x: 2, y: 3, width: 20, height: 16)

        NSColor.systemGray.withAlphaComponent(0.15).setFill()
        let bgPath = NSBezierPath(roundedRect: graphFrame, xRadius: 2, yRadius: 2)
        bgPath.fill()

        let history = monitor.cpuHistory
        guard history.count > 1 else { return }

        let path = NSBezierPath()
        let stepX = graphFrame.width / CGFloat(history.count - 1)

        for (index, value) in history.enumerated() {
            let x = graphFrame.origin.x + CGFloat(index) * stepX
            let normalized = min(value / 100.0, 1.0)
            let y = graphFrame.origin.y + graphFrame.height - (CGFloat(normalized) * graphFrame.height)

            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.line(to: CGPoint(x: x, y: y))
            }
        }

        let color: NSColor
        let cpuValue = monitor.cpuUsage
        if cpuValue > 80 {
            color = .systemRed
        } else if cpuValue > 50 {
            color = .systemOrange
        } else {
            color = .systemGreen
        }

        color.setStroke()
        path.lineWidth = 1.5
        path.stroke()

        let fillPath = path.copy() as! NSBezierPath
        fillPath.line(to: CGPoint(x: graphFrame.origin.x + graphFrame.width, y: graphFrame.origin.y))
        fillPath.line(to: CGPoint(x: graphFrame.origin.x, y: graphFrame.origin.y))
        fillPath.close()

        let gradient = NSGradient(starting: color.withAlphaComponent(0.4), ending: color.withAlphaComponent(0.05))
        gradient?.draw(in: fillPath, angle: 90)

        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 8, weight: .medium),
            .foregroundColor: color
        ]
        let text = String(format: "%.0f", monitor.cpuUsage)
        let textSize = text.size(withAttributes: textAttributes)
        let textRect = NSRect(
            x: graphFrame.maxX + 3,
            y: (bounds.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        text.draw(in: textRect, withAttributes: textAttributes)
    }

    func redraw() {
        needsDisplay = true
    }

    deinit {
        timer?.invalidate()
    }
}

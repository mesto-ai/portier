import SwiftUI
import AppKit

@main
struct PortMonitorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarController = StatusBarController()
    }
}

class StatusBarController {
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    private var monitor: Any?

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        popover = NSPopover()
        popover.contentSize = NSSize(width: 440, height: 580)
        popover.behavior = .transient
        popover.animates = true

        let portService = PortService()
        popover.contentViewController = NSHostingController(
            rootView: PortMonitorView(portService: portService)
                .frame(width: 440, height: 580)
        )

        if let button = statusItem.button {
            button.image = Self.createMestoIcon()
            button.action = #selector(togglePopover)
            button.target = self

            // Port count badge
            updateBadge(portService: portService)
        }

        // Auto-refresh badge
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.updateBadge(portService: portService)
        }
    }

    private func updateBadge(portService: PortService) {
        DispatchQueue.global(qos: .background).async {
            let ports = portService.fetchPorts()
            DispatchQueue.main.async { [weak self] in
                if let button = self?.statusItem.button {
                    let count = ports.count
                    button.title = count > 0 ? " \(count)" : ""
                }
            }
        }
    }

    /// Mesto AI logosunu NSImage olarak status bar için çizer (template image)
    private static func createMestoIcon() -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size, flipped: false) { rect in
            let scaleX = rect.width / 100
            let scaleY = rect.height / 110

            func p(_ x: CGFloat, _ y: CGFloat) -> NSPoint {
                NSPoint(x: x * scaleX, y: rect.height - y * scaleY)
            }

            let color = NSColor.white

            // Hexagon background
            let hex = NSBezierPath()
            hex.move(to: p(50, 5))
            hex.line(to: p(93.3, 30))
            hex.line(to: p(93.3, 80))
            hex.line(to: p(50, 105))
            hex.line(to: p(6.7, 80))
            hex.line(to: p(6.7, 30))
            hex.close()
            color.withAlphaComponent(0.2).setFill()
            hex.fill()

            // Lines
            color.setStroke()

            // Center vertical line
            let centerLine = NSBezierPath()
            centerLine.move(to: p(50, 35))
            centerLine.line(to: p(50, 75))
            centerLine.lineWidth = 6 * scaleX
            centerLine.lineCapStyle = .round
            centerLine.stroke()

            // V-shape left
            let vLeft = NSBezierPath()
            vLeft.move(to: p(50, 55))
            vLeft.line(to: p(25, 35))
            vLeft.lineWidth = 6 * scaleX
            vLeft.lineCapStyle = .round
            vLeft.stroke()

            // V-shape right
            let vRight = NSBezierPath()
            vRight.move(to: p(50, 55))
            vRight.line(to: p(75, 35))
            vRight.lineWidth = 6 * scaleX
            vRight.lineCapStyle = .round
            vRight.stroke()

            // Side lines (opacity 0.7)
            color.withAlphaComponent(0.7).setStroke()

            let leftSide = NSBezierPath()
            leftSide.move(to: p(25, 35))
            leftSide.line(to: p(25, 65))
            leftSide.lineWidth = 6 * scaleX
            leftSide.lineCapStyle = .round
            leftSide.stroke()

            let rightSide = NSBezierPath()
            rightSide.move(to: p(75, 35))
            rightSide.line(to: p(75, 65))
            rightSide.lineWidth = 6 * scaleX
            rightSide.lineCapStyle = .round
            rightSide.stroke()

            // Circles
            color.setFill()

            // Center circle r=8
            let cc = NSBezierPath(ovalIn: NSRect(
                x: (50 - 8) * scaleX,
                y: rect.height - (55 + 8) * scaleY,
                width: 16 * scaleX,
                height: 16 * scaleY
            ))
            cc.fill()

            // Left circle r=6
            let lc = NSBezierPath(ovalIn: NSRect(
                x: (25 - 6) * scaleX,
                y: rect.height - (35 + 6) * scaleY,
                width: 12 * scaleX,
                height: 12 * scaleY
            ))
            lc.fill()

            // Right circle r=6
            let rc = NSBezierPath(ovalIn: NSRect(
                x: (75 - 6) * scaleX,
                y: rect.height - (35 + 6) * scaleY,
                width: 12 * scaleX,
                height: 12 * scaleY
            ))
            rc.fill()

            return true
        }

        image.isTemplate = true
        return image
    }

    @objc func togglePopover() {
        if popover.isShown {
            popover.performClose(nil)
            if let monitor = monitor {
                NSEvent.removeMonitor(monitor)
                self.monitor = nil
            }
        } else {
            if let button = statusItem.button {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                monitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
                    self?.popover.performClose(nil)
                }
            }
        }
    }
}

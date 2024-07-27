import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var localEventMonitor: Any?
    var window: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        if #available(macOS 14.0, *) {
            NSApp.activate(ignoringOtherApps: true)
        } else {
            // Fallback on earlier versions
        }
        setupKeyboardShortcuts()
        setupWindow()
    }
    
    func setupWindow() {
        // Get the main window
        if let window = NSApplication.shared.windows.first {
            self.window = window
            
            // Set window level to floating (above normal windows)
            window.level = .floating
            
            // Make the window visible and bring it to the front
            window.makeKeyAndOrderFront(nil)
            
            // Set collection behavior to make it visible on all spaces
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            
            // Ensure the window is not minimizable or resizable
            window.styleMask.remove(.miniaturizable)
            window.styleMask.remove(.resizable)
        }
    }

    func setupKeyboardShortcuts() {
        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 53 { // 53 is the key code for Escape
                NSApp.terminate(nil)
                return nil
            }
            return event
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let monitor = localEventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}

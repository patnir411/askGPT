import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var overlayWindowController: OverlayWindowController?
    var eventMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        overlayWindowController = OverlayWindowController()
        overlayWindowController?.showWindow(nil)
        
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 53 {  // 53 is the key code for the Escape key
                NSApplication.shared.terminate(self)
            }
            return event
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}

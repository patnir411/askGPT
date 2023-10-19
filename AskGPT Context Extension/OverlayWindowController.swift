import Cocoa
import SwiftUI

class CustomWindow: NSWindow {
    override var canBecomeKey: Bool {
        return true
    }
}

class OverlayWindowController: NSWindowController {
    init() {
        let overlayWindow = CustomWindow(
            contentRect: NSRect(x: 0, y: 0, width: NSScreen.main?.frame.width ?? 800, height: NSScreen.main?.frame.height ?? 600),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        overlayWindow.contentView = NSHostingView(rootView: ContentView())
        overlayWindow.level = .modalPanel
        overlayWindow.backgroundColor = NSColor.clear
        overlayWindow.isOpaque = false
        overlayWindow.ignoresMouseEvents = false // Allow mouse events
        
        
        super.init(window: overlayWindow)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  AskGPTContextExtensionApp.swift
//  AskGPT Context Extension
//
//  Created by Niral Patel on 7/26/24.
//

import SwiftUI

@main
struct AskGPTContextExtensionApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }.windowStyle(.hiddenTitleBar)
    }
}


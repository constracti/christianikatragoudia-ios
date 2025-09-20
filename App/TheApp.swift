//
//  TheApp.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 22-04-2025.
//

import SwiftUI


// TODO make isPreview public

@main
struct TheApp: App {
    
    @UIApplicationDelegateAdaptor private var delegate: TheAppDelegate
    
    @State private var passed = false
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if passed {
                    SearchView()
                } else {
                    WelcomeView(passed: $passed)
                }
            }
        }
    }
}

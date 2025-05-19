//
//  TheApp.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 22-04-2025.
//

import SwiftUI


@main
struct TheApp: App {
    
    @State private var passed = false
    
    var body: some Scene {
        WindowGroup {
            if passed {
                SearchView()
            } else {
                WelcomeView(passed: $passed)
            }
        }
    }
}

//
//  TheAppDelegate.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 26-05-2025.
//

import UIKit
import FirebaseCore
import FirebaseAnalytics


// https://firebase.google.com/docs/analytics/get-started?platform=ios
// https://developer.apple.com/documentation/swiftui/uiapplicationdelegateadaptor
// https://developer.apple.com/documentation/uikit/uiapplicationdelegate/application(_:didfinishlaunchingwithoptions:)

class TheAppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

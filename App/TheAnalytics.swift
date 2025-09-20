//
//  TheAnalytics.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 28-05-2025.
//

import FirebaseAnalytics


// TODO app open and share events

class TheAnalytics {
    
    private static let EVENT_UPDATE_CHECK: String = "update_check"
    private static let EVENT_UPDATE_APPLY: String = "update_apply"
    
    static func logUpdateCheck() -> Void {
        Analytics.logEvent(EVENT_UPDATE_CHECK, parameters: nil)
    }
    
    static func logUpdateApply() -> Void {
        Analytics.logEvent(EVENT_UPDATE_APPLY, parameters: nil)
    }
}

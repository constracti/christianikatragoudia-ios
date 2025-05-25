//
//  Version.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 24-05-2025.
//

import SwiftUICore


class Version {
    let tag: String
    let changes: String
    let date: String
    
    static let CURRENT: String = "1.0.0"
    
    static let ALL: [Version] = [
        Version(tag: "1.0", changes: String(localized: "Version_1"), date: "26-05-2025"),
    ]
    
    init(tag: String, changes: String, date: String) {
        self.tag = tag
        self.changes = changes
        self.date = date
    }
}

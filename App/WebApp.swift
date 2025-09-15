//
//  WebApp.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 25-05-2025.
//

import Foundation


class WebApp {
    
    private static let homeComponents: URLComponents = URLComponents(string: "https://christianikatragoudia.gr/")!
    
    static var homeUrl: URL {
        homeComponents.url!
    }
    
    static var homeHost: String {
        homeComponents.host!
    }
    
    static var homeString: String {
        homeComponents.string!
    }
    
    static var mailString: String {
        "info@" + homeHost
    }
    
    static var mailUrl: URL {
        URL(string: "mailto:" + mailString)!
    }
    
    static var ajaxUrl: URL {
        homeUrl.appending(components: "wp-admin", "admin-ajax.php")
    }
    
    static func getUpdateTimestamp() async -> Int? {
        let url = ajaxUrl.appending(queryItems: [
            URLQueryItem(name: "action", value: "xt_app_notification_1"),
        ])
        do {
            let tuple = try await URLSession.shared.data(from: url)
            let (data, response) = (tuple.0, tuple.1 as! HTTPURLResponse)
            if response.statusCode != 200 {
                throw WebAppError.status(statusCode: response.statusCode)
            }
            return try JSONDecoder().decode(Int.self, from: data)
        } catch {
            return nil
        }
    }
}


enum WebAppError: Error {
    case status(statusCode: Int)
}

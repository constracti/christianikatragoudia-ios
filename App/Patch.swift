//
//  Patch.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 02-05-2025.
//

import Foundation


class Patch: Decodable {
    let timestamp: Int
    let songIdSet: Set<Int>
    let chordIdSet: Set<Int>
    let songList: [Song]
    let chordList: [Chord]
    
    init(timestamp: Int, songIdSet: Set<Int>, chordIdSet: Set<Int>, songList: [Song], chordList: [Chord]) {
        self.timestamp = timestamp
        self.songIdSet = songIdSet
        self.chordIdSet = chordIdSet
        self.songList = songList
        self.chordList = chordList
    }
    
    private enum CodingKeys: String, CodingKey {
        case timestamp
        case songIdSet = "song_id_list"
        case chordIdSet = "chord_id_list"
        case songList = "song_list"
        case chordList = "chord_list"
        
    }

    static func get(after: Int?, full: Bool) async -> Patch? {
        let queryItems = [
            URLQueryItem(name: "action", value: "xt_app_patch_2"),
            URLQueryItem(name: "after", value: after != nil ? String(after!) : nil),
            URLQueryItem(name: "full", value: String(full)),
        ]
        let url: URL
        if #available(iOS 16.0, *) {
            url = WebApp.ajaxUrl.appending(queryItems: queryItems)
        } else {
            var urlComp = URLComponents(string: WebApp.ajaxUrl.absoluteString)!
            urlComp.queryItems = queryItems
            url = urlComp.url!
        }
        do {
            let tuple = try await URLSession.shared.data(from: url)
            let (data, response) = (tuple.0, tuple.1 as! HTTPURLResponse)
            if response.statusCode != 200 {
                throw WebAppError.status(statusCode: response.statusCode)
            }
            return try JSONDecoder().decode(Patch.self, from: data)
        } catch {
            return nil
        }
    }
}

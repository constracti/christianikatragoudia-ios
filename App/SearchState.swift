//
//  SearchState.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 24-05-2025.
//

import SwiftUI


class SearchState {
    let query: String
    let resultList: [SongTitle]
    let updateCheck: Bool
    
    init(query: String, resultList: [SongTitle], updateCheck: Bool) {
        self.query = query
        self.resultList = resultList
        self.updateCheck = updateCheck
    }
    
    init(db: TheDatabase, query: String, updateCheck: Bool) {
        self.query = query
        if query.isEmpty {
            self.resultList = SongTitle.getAll(db: db)
        } else {
            // TODO prioritize consecutive search tokens
            let fullTextQuery = SongFts
                .tokenize(inString: query)
                .components(separatedBy: " ")
                .map { "\"\($0)\" OR \"\($0)*\""}
                .joined(separator: " OR ")
            self.resultList = SongMatch
                .getByQuery(db: db, query: fullTextQuery)
                .map { SongTitle(songMatch: $0) }
        }
        self.updateCheck = updateCheck
    }
    
    static func cachedUpdateCheck(db: TheDatabase) -> Bool {
        Config.getUpdateCheck(db: db) ?? false
    }
    
    static func serverUpdateCheck(db: TheDatabase) async -> Bool {
        let oldTimestamp = Config.getUpdateTimestamp(db: db)!
        guard let newTimestamp = await WebApp.getUpdateTimestamp() else { return false }
        return oldTimestamp < newTimestamp
    }
    
    func copyWithUpdateCheck(updateCheck: Bool) -> SearchState {
        SearchState(query: self.query, resultList: self.resultList, updateCheck: updateCheck)
    }
}


extension Binding<SearchState?> {
    
    func bindQuery(isPreview: Bool) -> Binding<String> {
        Binding<String>(
            get: {
                guard let searchState = wrappedValue else { preconditionFailure() }
                return searchState.query
            },
            set: { query in
                guard let searchState = wrappedValue else { return }
                if isPreview { return }
                wrappedValue = SearchState(db: TheDatabase(), query: query, updateCheck: searchState.updateCheck)
            },
        )
    }
}

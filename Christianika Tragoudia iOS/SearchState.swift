//
//  SearchState.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 24-05-2025.
//


import SwiftUI


class SearchState {
    let query: String
    let resultList: [SongTitle]?
    let updateCheck: Bool?
    
    init(query: String = "", resultList: [SongTitle]? = nil, updateCheck: Bool? = nil) {
        self.query = query
        self.resultList = resultList
        self.updateCheck = updateCheck
    }
    
    static func getResultList(db: TheDatabase, query: String) async -> [SongTitle] {
        guard !query.isEmpty else {
            return SongTitle.getAll(db: db)
        }
        let fullTextQuery = SongFts
            .tokenize(inString: query)
            .components(separatedBy: " ")
            .map { "\"\($0)\" OR \"\($0)*\""}
            .joined(separator: " OR ")
        return SongMatch
            .getByQuery(db: db, query: fullTextQuery)
            .map { SongTitle(songMatch: $0) }
    }
    
    static func cachedUpdateCheck(db: TheDatabase) -> Bool {
        Config.getUpdateCheck(db: db) ?? false
    }
    
    static func serverUpdateCheck(db: TheDatabase) async -> Bool {
        let oldTimestamp = Config.getUpdateTimestamp(db: db)!
        guard let newTimestamp = await WebApp.getUpdateTimestamp() else { return false }
        return oldTimestamp < newTimestamp
    }
    
    func copyWithQuery(query: String) -> SearchState {
        SearchState(query: query, resultList: self.resultList, updateCheck: self.updateCheck)
    }
    
    func copyWithResultList(resultList: [SongTitle]?) -> SearchState {
        SearchState(query: self.query, resultList: resultList, updateCheck: self.updateCheck)
    }
    
    func copyWithUpdateCheck(updateCheck: Bool?) -> SearchState {
        SearchState(query: self.query, resultList: self.resultList, updateCheck: updateCheck)
    }
}


extension Binding<SearchState> {
    
    func bindQuery() -> Binding<String> {
        Binding<String>(
            get: {
                self.wrappedValue.query
            },
            set: { query in
                self.wrappedValue = self.wrappedValue.copyWithQuery(query: query)
                Task {
                    self.wrappedValue = await self.wrappedValue
                        .copyWithResultList(resultList: SearchState.getResultList(db: TheDatabase(), query: self.wrappedValue.query))
                }
            },
        )
    }
}

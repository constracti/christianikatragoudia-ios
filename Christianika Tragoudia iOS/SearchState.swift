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
    
    init(query: String = "", resultList: [SongTitle]? = nil) {
        self.query = query
        self.resultList = resultList
    }
    
    func search() async -> [SongTitle] {
        guard !query.isEmpty else {
            return SongTitle.getAll(db: TheDatabase())
        }
        let fullTextQuery = SongFts
            .tokenize(inString: query)
            .components(separatedBy: " ")
            .map { "\"\($0)\" OR \"\($0)*\""}
            .joined(separator: " OR ")
        return SongMatch
            .getByQuery(db: TheDatabase(), query: fullTextQuery)
            .map { SongTitle(songMatch: $0) }
    }
    
    func copyWithQuery(query: String) -> SearchState {
        SearchState(query: query, resultList: self.resultList)
    }
    
    func copyWithResultList(resultList: [SongTitle]?) -> SearchState {
        SearchState(query: self.query, resultList: resultList)
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
                    self.wrappedValue = await self.wrappedValue.copyWithResultList(resultList: self.wrappedValue.search())
                }
            },
        )
    }
}

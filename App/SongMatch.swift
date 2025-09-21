//
//  SongMatch.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 05-05-2025.
//

import Foundation


class SongMatch: Comparable {
    let id: Int
    let title: String
    let excerpt: String
    let score: Double
    
    init(id: Int, title: String, excerpt: String, score: Double) {
        self.id = id
        self.title = title
        self.excerpt = excerpt
        self.score = score
    }
    
    private init(id: Int, title: String, excerpt: String, matchinfo: Data) {
        self.id = id
        self.title = title
        self.excerpt = excerpt
        self.score = SongMatch.getScore(matchinfo: matchinfo)
    }
    
    private convenience init(stmt: Statement) {
        self.init(
            id: stmt.readInt(index: 0),
            title: stmt.readString(index: 1),
            excerpt: stmt.readString(index: 2),
            matchinfo: stmt.readData(index: 3),
        )
    }
    
    static func <=> (lhs: SongMatch, rhs: SongMatch) -> Spaceship? {
        (-lhs.score <=> -rhs.score) ?? (lhs.title <=> rhs.title) ?? (lhs.excerpt <=> rhs.excerpt) ?? (lhs.id <=> rhs.id)
    }
    
    static func < (lhs: SongMatch, rhs: SongMatch) -> Bool {
        (lhs <=> rhs) == .asc
    }
    
    static func == (lhs: SongMatch, rhs: SongMatch) -> Bool {
        (lhs <=> rhs) == nil
    }
    
    private static func getScore(matchinfo: Data) -> Double {
        let info = matchinfo.reduce((Array<UInt32>(), Array<UInt8>()), { acc, val in
            var ret = acc
            ret.1.append(val)
            if ret.1.count == 4 {
                ret.0.append(ret.1.reversed().reduce(UInt32(0), { acc, val in
                    (acc << 8) | UInt32(val)
                }))
                ret.1 = Array<UInt8>()
            }
            return ret
        }).0
        let columnCount = Int(info[1])
        let columnSize = 3
        let phraseCount = Int(info[0])
        let phraseSize = columnSize * columnCount
        var score = 0.0
        for phraseIndex in 0..<phraseCount {
            for columnIndex in 0..<columnCount {
                let infoBase = 2 + phraseIndex * phraseSize + columnIndex * columnSize
                let columnWeight = SongFts.getColumnWeight(columnIndex: columnIndex)
                let phraseFrequency = Int(info[infoBase + 1])
                if phraseFrequency == 0 {
                    continue
                }
                let phraseMatches = Int(info[infoBase + 0])
                score += Double(phraseMatches) / Double(phraseFrequency) * columnWeight
            }
        }
        return score
    }
    
    static func getByQuery(db: TheDatabase, query: String) -> [SongMatch] {
        let sql = """
            SELECT `song`.`id`, `song`.`title`, `song`.`excerpt`, matchinfo(`song_fts`) as `matchinfo`
            FROM `song_fts`
            JOIN `song` ON `song`.`id` = `song_fts`.`rowid`
            JOIN `chord` ON `chord`.`parent` = `song`.`id`
            WHERE `song_fts` MATCH ?
            """
        let tokenList = SongFts.tokenize(value: query)
            .split(separator: " ")
        guard tokenList.count > 0 else { return [] }
        // limit to (1 + 2 + 3) * 2 = 12 terms
        let maxLength = tokenList.count
        let minLength = max(maxLength - 2, 1)
        var termList: [String] = []
        for length in minLength...maxLength {
            for start in 0...(tokenList.count - length) {
                let stop = start + length
                let subList = tokenList[start..<stop]
                termList.append(subList.joined(separator: " "))
                termList.append(subList.map({ "\($0)*" }).joined(separator: " "))
            }
        }
        let expr = termList.map({ "\"\($0)\"" }).joined(separator: " OR ")
        var list = [SongMatch]()
        let stmt = Statement(db: db, sql: sql)
        stmt.bindString(index: 1, value: expr)
        while stmt.step() == .ROW {
            list.append(SongMatch(stmt: stmt))
        }
        return list.sorted()
    }
}

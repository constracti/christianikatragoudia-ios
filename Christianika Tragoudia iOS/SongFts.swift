//
//  SongFts.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 04-05-2025.
//


class SongFts {
    
    let rowid: Int
    let title: String
    let content: String
    
    init(rowid: Int, title: String, content: String) {
        self.rowid = rowid
        self.title = title
        self.content = content
    }
    
    init(song: Song) {
        self.rowid = song.id
        self.title = SongFts.tokenize(inString: song.title)
        self.content = SongFts.tokenize(inString: song.content)
    }
    
    static func create(db: TheDatabase) {
        let sql = """
            CREATE VIRTUAL TABLE IF NOT EXISTS `song_fts` USING FTS4(
                `title` TEXT NOT NULL,
                `content` TEXT NOT NULL
            )
            """
        let stmt = Statement(db: db, sql: sql)
        stmt.stepDone()
    }
    
    static func drop(db: TheDatabase) {
        let sql = "DROP TABLE IF EXISTS `song_fts`"
        let stmt = Statement(db: db, sql: sql)
        stmt.stepDone()
    }
    
    static func insert(db: TheDatabase, ftsList: Array<SongFts>) {
        let sql = """
            INSERT INTO `song_fts` (
                `rowid`,
                `title`,
                `content`
            ) VALUES (?, ?, ?)
            """
        let stmt = Statement(db: db, sql: sql)
        for fts in ftsList {
            stmt.bindInt(index: 1, value: fts.rowid)
            stmt.bindString(index: 2, value: fts.title)
            stmt.bindString(index: 3, value: fts.content)
            stmt.stepDone()
            stmt.reset()
        }
    }
    
    static func optimize(db: TheDatabase) {
        let sql = "INSERT INTO `song_fts`(`song_fts`) VALUES ('optimize')"
        let stmt = Statement(db: db, sql: sql)
        stmt.stepDone()
    }
    
    static func tokenize(inString: String) -> String {
        var outString = inString.localizedLowercase
        if #available(iOS 16.0, *) {
            outString = outString.replacing(/<[^>]*>/, with: " ")
        } else {
            outString = outString.replacingOccurrences(of: "<[^>]*>", with: " ", options: .regularExpression)
        }
        outString = outString.decomposedStringWithCanonicalMapping.unicodeScalars.reduce("", { acc, scalar in
            var ret = acc
            switch scalar.properties.generalCategory {
            case .lowercaseLetter,
                    .decimalNumber:
                ret.unicodeScalars.append(scalar)
            case .nonspacingMark:
                break
            default:
                ret.unicodeScalars.append(" ")
            }
            return ret
        })
        if #available(iOS 16.0, *) {
            outString = outString.replacing(/\s+/, with: " ")
        } else {
            outString = outString.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        }
        outString = outString.trimmingCharacters(in: .whitespacesAndNewlines)
        return outString
    }
    
    static func getColumnWeight(columnIndex: Int) -> Double {
        switch columnIndex {
        case 0:
            return 2.0
        default:
            return 1.0
        }
    }
}

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
        self.title = SongFts.tokenize(value: song.title)
        self.content = SongFts.tokenize(value: song.content)
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
    
    static func insert(db: TheDatabase, ftsList: [SongFts]) {
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
    
    static func update(db: TheDatabase, ftsList: [SongFts]) {
        let sql = """
            UPDATE `song_fts`
            SET
                `title` = ?,
                `content` = ?
            WHERE `rowid` = ?
            """
        let stmt = Statement(db: db, sql: sql)
        for fts in ftsList {
            stmt.bindString(index: 1, value: fts.title)
            stmt.bindString(index: 2, value: fts.content)
            stmt.bindInt(index: 3, value: fts.rowid)
            stmt.stepDone()
            stmt.reset()
        }
    }
    
    static func delete(db: TheDatabase, ftsList: [SongFts]) {
        let sql = """
            DELETE FROM `song_fts`
            WHERE `rowid` = ?
            """
        let stmt = Statement(db: db, sql: sql)
        for fts in ftsList {
            stmt.bindInt(index: 1, value: fts.rowid)
            stmt.stepDone()
            stmt.reset()
        }
    }
    
    static func optimize(db: TheDatabase) {
        let sql = "INSERT INTO `song_fts`(`song_fts`) VALUES ('optimize')"
        let stmt = Statement(db: db, sql: sql)
        stmt.stepDone()
    }
    
    static func tokenize(value: String) -> String {
        value
            .localizedLowercase
            .replacing(/<[^>]*>/, with: " ")
            .decomposedStringWithCanonicalMapping
            .unicodeScalars
            .map({ scalar in
                switch scalar {
                case Unicode.Scalar(0x03c2)!: // small final sigma
                    Unicode.Scalar(0x03c3)! // small sigma
                default:
                    scalar
                }
            })
            .reduce(into: "", { result, scalar in
                switch scalar.properties.generalCategory {
                case .lowercaseLetter,
                        .decimalNumber:
                    result.unicodeScalars.append(scalar)
                case .nonspacingMark:
                    break
                default:
                    result.unicodeScalars.append(" ")
                }
            })
            .replacing(/\s+/, with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    static func getColumnWeight(columnIndex: Int) -> Double {
        switch columnIndex {
        case 0:
            2.0
        default:
            1.0
        }
    }
}

//
//  Chord.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 02-05-2025.
//


class Chord: Decodable {
    
    let id: Int
    let date: String
    let modified: String
    let parent: Int
    let content: String
    let tonality: MusicNote
    
    init(id: Int, date: String, modified: String, parent: Int, content: String, tonality: MusicNote) {
        self.id = id
        self.date = date
        self.modified = modified
        self.parent = parent
        self.content = content
        self.tonality = tonality
    }
    
    static func create(db: TheDatabase) {
        let sql = """
            CREATE TABLE IF NOT EXISTS `chord` (
                `id` INTEGER NOT NULL,
                `date` TEXT NOT NULL,
                `modified` TEXT NOT NULL,
                `parent` INTEGER NOT NULL,
                `content` TEXT NOT NULL,
                `tonality` TEXT NOT NULL,
                PRIMARY KEY(`id`),
                FOREIGN KEY(`parent`) REFERENCES `song`(`id`) ON UPDATE CASCADE ON DELETE CASCADE
            )
            """
        let stmt = Statement(db: db, sql: sql)
        stmt.stepDone()
    }
    
    static func drop(db: TheDatabase) {
        let sql = "DROP TABLE IF EXISTS `chord`"
        let stmt = Statement(db: db, sql: sql)
        stmt.stepDone()
    }
    
    func count(db: TheDatabase) -> Int {
        let sql = "SELECT COUNT(*) FROM `chord`"
        let stmt = Statement(db: db, sql: sql)
        stmt.stepRow()
        return stmt.readInt(index: 0)
    }
    
    static func insert(db: TheDatabase, chordList: Array<Chord>) {
        let sql = """
            INSERT INTO `chord` (
                `id`,
                `date`,
                `modified`,
                `parent`,
                `content`,
                `tonality`
            ) VALUES (?, ?, ?, ?, ?, ?)
            """
        let stmt = Statement(db: db, sql: sql)
        for chord in chordList {
            stmt.bindInt(index: 1, value: chord.id)
            stmt.bindString(index: 2, value: chord.date)
            stmt.bindString(index: 3, value: chord.modified)
            stmt.bindInt(index: 4, value: chord.parent)
            stmt.bindString(index: 5, value: chord.content)
            stmt.bindTonality(index: 6, value: chord.tonality)
            stmt.stepDone()
            stmt.reset()
        }
    }
    
    static func getByParent(db: TheDatabase, parent: Int) -> Chord? {
        let sql = """
            SELECT `id`, `date`, `modified`, `parent`, `content`, `tonality`
            FROM `chord`
            WHERE `parent` = ?
            """
        let stmt = Statement(db: db, sql: sql)
        stmt.bindInt(index: 1, value: parent)
        if stmt.step() == .DONE {
            return nil
        }
        return Chord(
            id: stmt.readInt(index: 0),
            date: stmt.readString(index: 1),
            modified: stmt.readString(index: 2),
            parent: stmt.readInt(index: 3),
            content: stmt.readString(index: 4),
            tonality: stmt.readTonality(index: 5),
        )
    }
}

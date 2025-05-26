//
//  Song.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 01-05-2025.
//


class Song: Decodable {
    let id: Int
    let date: String
    let content: String
    let title: String
    let excerpt: String
    let modified: String
    let permalink: String

    init(id: Int, date: String, content: String, title: String, excerpt: String, modified: String, permalink: String) {
        self.id = id
        self.date = date
        self.content = content
        self.title = title
        self.excerpt = excerpt
        self.modified = modified
        self.permalink = permalink
    }
    
    private init(stmt: Statement) {
        self.id = stmt.readInt(index: 0)
        self.date = stmt.readString(index: 1)
        self.content = stmt.readString(index: 2)
        self.title = stmt.readString(index: 3)
        self.excerpt = stmt.readString(index: 4)
        self.modified = stmt.readString(index: 5)
        self.permalink = stmt.readString(index: 6)
    }
    
    static func create(db: TheDatabase) -> Void {
        let sql = """
            CREATE TABLE IF NOT EXISTS `song` (
                `id` INTEGER NOT NULL,
                `date` TEXT NOT NULL,
                `content` TEXT NOT NULL,
                `title` TEXT NOT NULL,
                `excerpt` TEXT NOT NULL,
                `modified` TEXT NOT NULL,
                `permalink` TEXT NOT NULL,
                PRIMARY KEY(`id`)
            )
            """
        let stmt = Statement(db: db, sql: sql)
        stmt.stepDone()
    }

    static func drop(db: TheDatabase) -> Void {
        let sql = "DROP TABLE IF EXISTS `song`"
        let stmt = Statement(db: db, sql: sql)
        stmt.stepDone()
    }

    static func count(db: TheDatabase) -> Int {
        let sql = "SELECT COUNT(*) FROM `song`"
        let stmt = Statement(db: db, sql: sql)
        stmt.stepRow()
        return stmt.readInt(index: 0)
    }

    static func insert(db: TheDatabase, songList: [Song]) {
        let sql = """
            INSERT INTO `song` (
                `id`,
                `date`,
                `content`,
                `title`,
                `excerpt`,
                `modified`,
                `permalink`
            ) VALUES (?, ?, ?, ?, ?, ?, ?)
            """
        let stmt = Statement(db: db, sql: sql)
        for song in songList {
            stmt.bindInt(index: 1, value: song.id)
            stmt.bindString(index: 2, value: song.date)
            stmt.bindString(index: 3, value: song.content)
            stmt.bindString(index: 4, value: song.title)
            stmt.bindString(index: 5, value: song.excerpt)
            stmt.bindString(index: 6, value: song.modified)
            stmt.bindString(index: 7, value: song.permalink)
            stmt.stepDone()
            stmt.reset()
        }
    }
    
    static func update(db: TheDatabase, songList: [Song]) {
        let sql = """
            UPDATE `song`
            SET
                `date` = ?,
                `content` = ?,
                `title` = ?,
                `excerpt` = ?,
                `modified` = ?,
                `permalink` = ?
            WHERE `id` = ?
            """
        let stmt = Statement(db: db, sql: sql)
        for song in songList {
            stmt.bindString(index: 1, value: song.date)
            stmt.bindString(index: 2, value: song.content)
            stmt.bindString(index: 3, value: song.title)
            stmt.bindString(index: 4, value: song.excerpt)
            stmt.bindString(index: 5, value: song.modified)
            stmt.bindString(index: 6, value: song.permalink)
            stmt.bindInt(index: 7, value: song.id)
            stmt.stepDone()
            stmt.reset()
        }
    }
    
    static func delete(db: TheDatabase, songList: [Song]) {
        let sql = """
            DELETE FROM `song`
            WHERE `id` = ?
            """
        let stmt = Statement(db: db, sql: sql)
        for song in songList {
            stmt.bindInt(index: 1, value: song.id)
            stmt.stepDone()
            stmt.reset()
        }
    }
    
    static func getById(db: TheDatabase, id: Int) -> Song? {
        let sql = """
            SELECT `id`, `date`, `content`, `title`, `excerpt`, `modified`, `permalink`
            FROM `song`
            WHERE `id` = ?
            """
        let stmt = Statement(db: db, sql: sql)
        stmt.bindInt(index: 1, value: id)
        if stmt.step() == .DONE {
            return nil
        }
        return Song(stmt: stmt)
    }
    
    static func getAll(db: TheDatabase) -> [Song] {
        let sql = """
            SELECT `id`, `date`, `content`, `title`, `excerpt`, `modified`, `permalink`
            FROM `song`
            """
        let stmt = Statement(db: db, sql: sql)
        var list = [Song]()
        while stmt.step() == .ROW {
            list.append(Song(stmt: stmt))
        }
        return list
    }
    
    static func getAllWithoutContent(db: TheDatabase) -> [Song] {
        let sql = """
            SELECT `id`, `date`, '' AS `content`, `title`, `excerpt`, `modified`, `permalink`
            FROM `song`
            """
        let stmt = Statement(db: db, sql: sql)
        var list = [Song]()
        while stmt.step() == .ROW {
            list.append(Song(stmt: stmt))
        }
        return list
    }
}

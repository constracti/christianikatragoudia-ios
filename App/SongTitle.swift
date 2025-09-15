//
//  SongTitle.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 03-05-2025.
//


class SongTitle: Identifiable, Comparable {
    let id: Int
    let title: String
    let excerpt: String
    
    init(id: Int, title: String, excerpt: String) {
        self.id = id
        self.title = title
        self.excerpt = String(excerpt.split(separator: /\r\n|\r|\n/).first!)
    }
    
    convenience init(song: Song) {
        self.init(id: song.id, title: song.title, excerpt: song.excerpt)
    }
    
    convenience init(songMatch: SongMatch) {
        self.init(id: songMatch.id, title: songMatch.title, excerpt: songMatch.excerpt)
    }
    
    private convenience init(stmt: Statement) {
        self.init(
            id: stmt.readInt(index: 0),
            title: stmt.readString(index: 1),
            excerpt: stmt.readString(index: 2),
        )
    }
    
    static func <=> (lhs: SongTitle, rhs: SongTitle) -> Spaceship? {
        (lhs.title <=> rhs.title) ?? (lhs.excerpt <=> rhs.excerpt) ?? (lhs.id <=> rhs.id)
    }
    
    static func < (lhs: SongTitle, rhs: SongTitle) -> Bool {
        (lhs <=> rhs) == .asc
    }
    
    static func == (lhs: SongTitle, rhs: SongTitle) -> Bool {
        (lhs <=> rhs) == nil
    }

    static func getAll(db: TheDatabase) -> [SongTitle] {
        let sql = """
            SELECT `song`.`id`, `song`.`title`, `song`.`excerpt`
            FROM `song`
            JOIN `chord` ON `chord`.`parent` = `song`.`id`
            """
        var list = [SongTitle]()
        let stmt = Statement(db: db, sql: sql)
        while stmt.step() == .ROW {
            list.append(SongTitle(stmt: stmt))
        }
        return list.sorted()
    }
    
    static func getStarred(db: TheDatabase) -> [SongTitle] {
        let sql = """
            SELECT `song`.`id`, `song`.`title`, `song`.`excerpt`
            FROM `song`
            JOIN `chord` ON `chord`.`parent` = `song`.`id`
            JOIN `song_meta` ON `song_meta`.`id` = `song`.`id`
            WHERE `song_meta`.`starred`
            """
        var list = [SongTitle]()
        let stmt = Statement(db: db, sql: sql)
        while stmt.step() == .ROW {
            list.append(SongTitle(stmt: stmt))
        }
        return list.sorted()
    }
    
    static func getRecent(db: TheDatabase) -> [SongTitle] {
        let sql = """
            SELECT `song`.`id`, `song`.`title`, `song`.`excerpt`
            FROM `song`
            JOIN `chord` ON `chord`.`parent` = `song`.`id`
            JOIN `song_meta` ON `song_meta`.`id` = `song`.`id`
            WHERE `song_meta`.`visited` IS NOT NULL
            ORDER BY `song_meta`.`visited` DESC
            """
        var list = [SongTitle]()
        let stmt = Statement(db: db, sql: sql)
        while stmt.step() == .ROW {
            list.append(SongTitle(stmt: stmt))
        }
        return list
    }
}

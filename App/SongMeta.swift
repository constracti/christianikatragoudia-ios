//
//  SongMeta.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 14-05-2025.
//


class SongMeta {
    let id: Int
    let zoom: Double
    let starred: Bool
    let visited: String?
    
    init(id: Int, zoom: Double = 1.0, starred: Bool = false, visited: String? = nil) {
        self.id = id
        self.zoom = zoom
        self.starred = starred
        self.visited = visited
    }
    
    private init(stmt: Statement) {
        self.id = stmt.readInt(index: 0)
        self.zoom = stmt.readDouble(index: 1)
        self.starred = stmt.readBool(index: 2)
        self.visited = stmt.readStringNullable(index: 3)
    }
    
    static func create(db: TheDatabase) {
        let sql = """
            CREATE TABLE IF NOT EXISTS `song_meta` (
                `id` INTEGER NOT NULL,
                `zoom` REAL NOT NULL,
                `starred` INTEGER NOT NULL,
                `visited` TEXT,
                PRIMARY KEY(`id`),
                FOREIGN KEY(`id`) REFERENCES `song`(`id`) ON UPDATE CASCADE ON DELETE CASCADE
            )
            """
        let stmt = Statement(db: db, sql: sql)
        stmt.stepDone()
    }
    
    static func drop(db: TheDatabase) {
        let sql = "DROP TABLE IF EXISTS `song_meta`"
        let stmt = Statement(db: db, sql: sql)
        stmt.stepDone()
    }
    
    func upsert(db: TheDatabase) {
        let sql = """
            INSERT INTO `song_meta` (
                `id`,
                `zoom`,
                `starred`,
                `visited`
            ) VALUES (?, ?, ?, ?)
            ON CONFLICT (`id`) DO
            UPDATE
            SET
                `zoom` = `excluded`.`zoom`,
                `starred` = `excluded`.`starred`,
                `visited` = `excluded`.`visited`
            WHERE `id` = `excluded`.`id`
            """
        let stmt = Statement(db: db, sql: sql)
        stmt.bindInt(index: 1, value: id)
        stmt.bindDouble(index: 2, value: zoom)
        stmt.bindBool(index: 3, value: starred)
        stmt.bindStringNullable(index: 4, value: visited)
        stmt.stepDone()
    }
    
    static func getById(db: TheDatabase, id: Int) -> SongMeta {
        let sql = """
            SELECT `id`, `zoom`, `starred`, `visited`
            FROM `song_meta`
            WHERE `id` = ?
            """
        let stmt = Statement(db: db, sql: sql)
        stmt.bindInt(index: 1, value: id)
        if stmt.step() == .DONE {
            return SongMeta(id: id)
        }
        return SongMeta(stmt: stmt)
    }
    
    static func resetZoom(db: TheDatabase) -> Void {
        let sql = "UPDATE `song_meta` SET `zoom` = 1"
        let stmt = Statement(db: db, sql: sql)
        stmt.stepDone()
    }
    
    static func clearVisited(db: TheDatabase) -> Void {
        let sql = "UPDATE `song_meta` SET `visited` = NULL"
        let stmt = Statement(db: db, sql: sql)
        stmt.stepDone()
    }
    
    func copyWithZoom(zoom: Double) -> SongMeta {
        SongMeta(
            id: self.id,
            zoom: zoom,
            starred: self.starred,
            visited: self.visited,
        )
    }
    
    func copyWithStarred(starred: Bool) -> SongMeta {
        SongMeta(
            id: self.id,
            zoom: self.zoom,
            starred: starred,
            visited: self.visited,
        )
    }
    
    func copyWithVisited(visited: String) -> SongMeta {
        SongMeta(
            id: self.id,
            zoom: self.zoom,
            starred: self.starred,
            visited: visited,
        )
    }
}

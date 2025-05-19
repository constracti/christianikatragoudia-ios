//
//  ChordMeta.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 13-05-2025.
//


class ChordMeta {
    let id: Int
    let tonality: MusicNote?
    let zoom: Double
    
    init(id: Int, tonality: MusicNote? = nil, zoom: Double = 1.0) {
        self.id = id
        self.tonality = tonality
        self.zoom = zoom
    }
    
    static func create(db: TheDatabase) {
        let sql = """
            CREATE TABLE IF NOT EXISTS `chord_meta` (
                `id` INTEGER NOT NULL,
                `tonality` TEXT,
                `zoom` REAL NOT NULL,
                PRIMARY KEY(`id`),
                FOREIGN KEY(`id`) REFERENCES `chord`(`id`) ON UPDATE CASCADE ON DELETE CASCADE
            )
            """
        let stmt = Statement(db: db, sql: sql)
        stmt.stepDone()
    }
    
    static func drop(db: TheDatabase) {
        let sql = "DROP TABLE IF EXISTS `chord_meta`"
        let stmt = Statement(db: db, sql: sql)
        stmt.stepDone()
    }
    
    func upsert(db: TheDatabase) {
        let sql = """
            INSERT INTO `chord_meta` (
                `id`,
                `tonality`,
                `zoom`
            ) VALUES (?, ?, ?)
            ON CONFLICT (`id`) DO
            UPDATE
            SET
                `tonality` = `excluded`.`tonality`,
                `zoom` = `excluded`.`zoom`
            WHERE `id` = `excluded`.`id`
            """
        let stmt = Statement(db: db, sql: sql)
        stmt.bindInt(index: 1, value: id)
        stmt.bindTonalityNullable(index: 2, value: tonality)
        stmt.bindDouble(index: 3, value: zoom)
        stmt.stepDone()
    }
    
    static func getById(db: TheDatabase, id: Int) -> ChordMeta {
        let sql = """
            SELECT `id`, `tonality`, `zoom`
            FROM `chord_meta`
            WHERE `id` = ?
            """
        let stmt = Statement(db: db, sql: sql)
        stmt.bindInt(index: 1, value: id)
        if stmt.step() == .DONE {
            return ChordMeta(id: id)
        }
        return ChordMeta(
            id: stmt.readInt(index: 0),
            tonality: stmt.readTonalityNullable(index: 1),
            zoom: stmt.readDouble(index: 2),
        )
    }
    
    func copyWithTonality(tonality: MusicNote?) -> ChordMeta {
        ChordMeta(
            id: self.id,
            tonality: tonality,
            zoom: self.zoom,
        )
    }
    
    func copyWithZoom(zoom: Double) -> ChordMeta {
        ChordMeta(
            id: self.id,
            tonality: self.tonality,
            zoom: zoom,
        )
    }
}

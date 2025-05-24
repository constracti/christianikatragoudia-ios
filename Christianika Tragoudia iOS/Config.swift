//
//  Config.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 16-05-2025.
//

import Foundation


class Config {
    let key: String
    let value: String
    
    init(key: String, value: String) {
        self.key = key
        self.value = value
    }
    
    static func create(db: TheDatabase) {
        let sql = """
            CREATE TABLE IF NOT EXISTS `config` (
                `key` TEXT NOT NULL,
                `value` TEXT NOT NULL,
                PRIMARY KEY(`key`)
            )
            """
        let stmt = Statement(db: db, sql: sql)
        stmt.stepDone()
    }
    
    static func drop(db: TheDatabase) {
        let sql = "DROP TABLE IF EXISTS `config`"
        let stmt = Statement(db: db, sql: sql)
        stmt.stepDone()
    }
    
    private func upsert(db: TheDatabase) {
        let sql = """
            INSERT INTO `config` (
                `key`,
                `value`
            ) VALUES (?, ?)
            ON CONFLICT (`key`) DO
            UPDATE
            SET
                `value` = `excluded`.`value`
            WHERE `key` = `excluded`.`key`
            """
        let stmt = Statement(db: db, sql: sql)
        stmt.bindString(index: 1, value: key)
        stmt.bindString(index: 2, value: value)
        stmt.stepDone()
    }
    
    private static func getByKey(db: TheDatabase, key: String) -> Config? {
        let sql = """
            SELECT `key`, `value`
            FROM `config`
            WHERE `key` = ?
            """
        let stmt = Statement(db: db, sql: sql)
        stmt.bindString(index: 1, value: key)
        if stmt.step() == .DONE {
            return nil
        }
        return Config(
            key: stmt.readString(index: 0),
            value: stmt.readString(index: 1),
        )
    }
    
    private enum KEY: String {
        case VERSION = "version"
        case UPDATE_TIMESTAMP = "update_timestamp"
        case HIDDEN_TONALITIES = "hidden_tonalities"
    }

    private static func decode<T: Decodable>(value: String?) -> T? {
        guard let value else { return nil }
        let data = Data(value.utf8)
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    private static func encode<T: Encodable>(value: T?) -> String {
        let data = try! JSONEncoder().encode(value)
        return String(data: data, encoding: .utf8)!
    }
    
    private static func get<T: Decodable>(db: TheDatabase, key: KEY) -> T? {
        let config = getByKey(db: db, key: key.rawValue)
        return decode(value: config?.value)
    }
    
    private static func set<T: Encodable>(db: TheDatabase, key: KEY, value: T?) {
        let config = Config(key: key.rawValue, value: encode(value: value))
        config.upsert(db: db)
    }
    
    static func getVersion(db: TheDatabase) -> Int? {
        return get(db: db, key: .VERSION)
    }
    
    static func setVersion(db: TheDatabase, value: Int?) {
        set(db: db, key: .VERSION, value: value)
    }
    
    static func getUpdateTimestamp(db: TheDatabase) -> Int? {
        return get(db: db, key: .UPDATE_TIMESTAMP)
    }
    
    static func setUpdateTimestamp(db: TheDatabase, value: Int?) {
        set(db: db, key: .UPDATE_TIMESTAMP, value: value)
    }
    
    static func getHiddenTonalities(db: TheDatabase) -> Set<MusicNote>? {
        get(db: db, key: .HIDDEN_TONALITIES)
    }
    
    static func setHiddenTonalities(db: TheDatabase, value: Set<MusicNote>?) {
        set(db: db, key: .HIDDEN_TONALITIES, value: value)
    }
}

//
//  TheDatabase.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 01-05-2025.
//

import Foundation
import SQLite3


// TODO make database operations async

class TheDatabase {
    
    static private let version: Int = 1
    
    static private var initialized: Bool = false

    private var db: OpaquePointer!

    init() {
        open()
        if !TheDatabase.initialized {
            beginTransaction()
            Config.create(db: self)
            if let version = Config.getVersion(db: self) {
                precondition(version == TheDatabase.version)
            } else {
                Config.setVersion(db: self, value: TheDatabase.version)
            }
            Song.create(db: self)
            SongFts.create(db: self)
            SongMeta.create(db: self)
            Chord.create(db: self)
            ChordMeta.create(db: self)
            commitTransaction()
            TheDatabase.initialized = true
        }
    }
    
    func reinit() {
        TheDatabase.initialized = false
        beginTransaction()
        ChordMeta.drop(db: self)
        Chord.drop(db: self)
        SongMeta.drop(db: self)
        SongFts.drop(db: self)
        Song.drop(db: self)
        Config.drop(db: self)
        Config.create(db: self)
        Config.setVersion(db: self, value: TheDatabase.version)
        Song.create(db: self)
        SongFts.create(db: self)
        SongMeta.create(db: self)
        Chord.create(db: self)
        ChordMeta.create(db: self)
        commitTransaction()
        TheDatabase.initialized = true
    }

    private func open() {
        let url = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("db_main.sqlite")
        precondition(sqlite3_open(NSString(string: url.path()).utf8String!, &db) == SQLITE_OK)
    }

    func get() -> OpaquePointer! {
        db
    }

    deinit {
        precondition(sqlite3_close(db) == SQLITE_OK)
    }
    
    func beginTransaction() {
        let sql = "BEGIN TRANSACTION"
        let stmt = Statement(db: self, sql: sql)
        stmt.stepDone()
    }
    
    func commitTransaction() {
        let sql = "COMMIT TRANSACTION"
        let stmt = Statement(db: self, sql: sql)
        stmt.stepDone()
    }
}

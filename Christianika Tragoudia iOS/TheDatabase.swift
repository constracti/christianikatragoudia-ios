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

    // https://www.kodeco.com/6620276-sqlite-with-swift-tutorial-getting-started/
    private var db: OpaquePointer!

    init() {
        open()
        if !TheDatabase.initialized {
            Config.create(db: self)
            let version: Int? = Config.getVersion(db: self)
            if version == nil {
                Config.setVersion(db: self, value: TheDatabase.version)
            } else {
                assert(version == TheDatabase.version)
            }
            Song.create(db: self)
            SongFts.create(db: self)
            SongMeta.create(db: self)
            Chord.create(db: self)
            ChordMeta.create(db: self)
            TheDatabase.initialized = true
        }
    }
    
    func reinit() {
        TheDatabase.initialized = false
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
        TheDatabase.initialized = true
    }

    private func open() {
        let url = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("db_main.sqlite")
        assert(sqlite3_open(url.path, &db) == SQLITE_OK)
    }

    func get() -> OpaquePointer! {
        return db
    }

    deinit {
        if (db != nil) {
            assert(sqlite3_close(db) == SQLITE_OK)
        }
    }
}

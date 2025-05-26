//
//  Statement.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 18-05-2025.
//

import Foundation
import SQLite3


class Statement {
    
    private var stmt: OpaquePointer!
    
    init(db: TheDatabase, sql: String) {
        assert(sqlite3_prepare_v2(db.get(), sql, -1, &stmt, nil) == SQLITE_OK)
    }
    
    deinit {
        assert(sqlite3_finalize(stmt) == SQLITE_OK)
    }
    
    enum STEP {
        case DONE
        case ROW
    }
    
    func step() -> STEP {
        switch sqlite3_step(stmt) {
        case SQLITE_DONE:
            return .DONE
        case SQLITE_ROW:
            return .ROW
        default:
            assert(false)
        }
    }
    
    func stepDone() {
        assert(step() == .DONE)
    }
    
    func stepRow() {
        assert(step() == .ROW)
    }
    
    func reset() {
        assert(sqlite3_reset(stmt) == SQLITE_OK)
    }
    
    func bindBool(index: Int32, value: Bool) -> Void {
        bindInt(index: index, value: value ? 1 : 0)
    }
    
    func bindInt(index: Int32, value: Int) -> Void {
        assert(sqlite3_bind_int(stmt, index, Int32(value)) == SQLITE_OK)
    }
    
    func bindDouble(index: Int32, value: Double) -> Void {
        assert(sqlite3_bind_double(stmt, index, value) == SQLITE_OK)
    }
    
    func bindString(index: Int32, value: String) -> Void {
        assert(sqlite3_bind_text(stmt, index, NSString(string: value).utf8String, -1, nil) == SQLITE_OK)
    }
    
    func bindStringNullable(index: Int32, value: String?) -> Void {
        if value != nil {
            assert(sqlite3_bind_text(stmt, index, NSString(string: value!).utf8String, -1, nil) == SQLITE_OK)
        } else {
            assert(sqlite3_bind_null(stmt, index) == SQLITE_OK)
        }
    }
    
    func bindTonality(index: Int32, value: MusicNote) -> Void {
        bindString(index: index, value: value.notation)
    }
    
    func bindTonalityNullable(index: Int32, value: MusicNote?) -> Void {
        bindStringNullable(index: index, value: value?.notation)
    }
    
    func readBool(index: Int32) -> Bool {
        return readInt(index: index) > 0
    }
    
    func readInt(index: Int32) -> Int {
        let type = sqlite3_column_type(stmt, index)
        assert(type == SQLITE_INTEGER)
        return Int(sqlite3_column_int(stmt, index))
    }
    
    func readDouble(index: Int32) -> Double {
        let type = sqlite3_column_type(stmt, index)
        assert(type == SQLITE_FLOAT)
        return sqlite3_column_double(stmt, index)
    }
    
    func readString(index: Int32) -> String {
        let type = sqlite3_column_type(stmt, index)
        assert(type == SQLITE_TEXT)
        return String(cString: sqlite3_column_text(stmt, index))
    }
    
    func readStringNullable(index: Int32) -> String? {
        let type = sqlite3_column_type(stmt, index)
        if type == SQLITE_NULL {
            return nil
        }
        assert(type == SQLITE_TEXT)
        return String(cString: sqlite3_column_text(stmt, index))
    }
    
    func readTonality(index: Int32) -> MusicNote {
        let notation = readString(index: index)
        return MusicNote(notation: notation)!
    }
    
    func readTonalityNullable(index: Int32) -> MusicNote? {
        guard let notation = readStringNullable(index: index) else {
            return nil
        }
        return MusicNote(notation: notation)
    }
    
    func readData(index: Int32) -> Data {
        let type = sqlite3_column_type(stmt, index)
        assert(type == SQLITE_BLOB)
        return Data(
            bytes: sqlite3_column_blob(stmt, index),
            count: Int(sqlite3_column_bytes(stmt, index)),
        )
    }
}

//
//  MusicAlter.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 10-05-2025.
//


enum MusicAlter: CaseIterable {
    case DOUBLE_FLAT
    case FLAT
    case NATURAL
    case SHARP
    case DOUBLE_SHARP
    
    var symbol: String {
        switch self {
        case .DOUBLE_FLAT: "bb"
        case .FLAT: "b"
        case .NATURAL: ""
        case .SHARP: "#"
        case .DOUBLE_SHARP: "x"
        }
    }
    
    var semitones: Int {
        switch self {
        case .DOUBLE_FLAT: -2
        case .FLAT: -1
        case .NATURAL: 0
        case .SHARP: 1
        case .DOUBLE_SHARP: 2
        }
    }
    
    private static let symbol2alter = Dictionary(uniqueKeysWithValues: zip(
        MusicAlter.allCases.map { $0.symbol },
        MusicAlter.allCases,
    ))
    
    private static let semitones2alter = Dictionary(uniqueKeysWithValues: zip(
        MusicAlter.allCases.map { $0.semitones },
        MusicAlter.allCases,
    ))
    
    static func getBySymbol(symbol: String) -> MusicAlter? {
        symbol2alter[symbol]
    }
    
    static func getBySemitones(semitones: Int) -> MusicAlter? {
        semitones2alter[semitones]
    }
}

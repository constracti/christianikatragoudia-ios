//
//  MusicStep.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 10-05-2025.
//


enum MusicStep: CaseIterable {
    case C
    case D
    case E
    case F
    case G
    case A
    case B
    
    var name: Character {
        return switch self {
        case .C: "C"
        case .D: "D"
        case .E: "E"
        case .F: "F"
        case .G: "G"
        case .A: "A"
        case .B: "B"
        }
    }
    
    var diatonic: Int {
        return switch self {
        case .C: 0
        case .D: 1
        case .E: 2
        case .F: 3
        case .G: 4
        case .A: 5
        case .B: 6
        }
    }
    
    var chromatic: Int {
        return switch self {
        case .C: 0
        case .D: 2
        case .E: 4
        case .F: 5
        case .G: 7
        case .A: 9
        case .B: 11
        }
    }
    
    private static let name2step = Dictionary(uniqueKeysWithValues: zip(
        MusicStep.allCases.map { $0.name },
        MusicStep.allCases,
    ))
    
    private static let diatonic2step = Dictionary(uniqueKeysWithValues: zip(
        MusicStep.allCases.map { $0.diatonic },
        MusicStep.allCases,
    ))
    
    static func getByName(name: Character) -> MusicStep? {
        return name2step[name]
    }
    
    static func getByDiatonic(diatonic: Int) -> MusicStep? {
        return diatonic2step[diatonic]
    }
}

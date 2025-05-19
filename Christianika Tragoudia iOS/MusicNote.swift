//
//  MusicNote.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 10-05-2025.
//


class MusicNote: Identifiable, Hashable, Decodable {
    let step: MusicStep
    let alter: MusicAlter
    
    static func == (lhs: MusicNote, rhs: MusicNote) -> Bool {
        return lhs.step == rhs.step && lhs.alter == rhs.alter
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(step)
        hasher.combine(alter)
    }
    
    init(step: MusicStep, alter: MusicAlter) {
        self.step = step
        self.alter = alter
    }
    
    var notation: String {
        return "\(step.name)\(alter.symbol)"
    }
    
    convenience init?(notation: String) {
        let name = notation[notation.startIndex]
        guard let step = MusicStep.getByName(name: name) else {
            return nil
        }
        let symbol = String(notation[notation.index(after: notation.startIndex)...])
        guard let alter = MusicAlter.getBySymbol(symbol: symbol) else {
            return nil
        }
        self.init(step: step, alter: alter)
    }
    
    required convenience init(from decoder: any Decoder) throws {
        let notation = try String(from: decoder)
        self.init(notation: notation)!
    }
    
    static let TONALITIES: Array<MusicNote> = MusicStep.allCases.flatMap { step in
        [
            MusicNote(step: step, alter: MusicAlter.FLAT),
            MusicNote(step: step, alter: MusicAlter.NATURAL),
            MusicNote(step: step, alter: MusicAlter.SHARP),
        ]
    }
    
    static let ENHARMONIC_TONALITIES: Set<MusicNote> = Set(Array(arrayLiteral: "Cb", "Db", "D#", "E#", "Fb", "Gb", "G#", "A#", "B#").map { notation in
        MusicNote(notation: notation)!
    })
    
    static let NOTATION_ERROR: String = "?"
}

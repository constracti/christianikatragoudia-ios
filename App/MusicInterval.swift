//
//  MusicInterval.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 11-05-2025.
//


class MusicInterval {
    private let diatonic: Int
    private let chromatic: Int
    
    init(diatonic: Int, chromatic: Int) {
        self.diatonic = diatonic
        self.chromatic = chromatic
    }
    
    convenience init(src: MusicNote, dst: MusicNote) {
        let diatonic = dst.step.diatonic - src.step.diatonic
        let chromatic = dst.step.chromatic + dst.alter.semitones - src.step.chromatic - src.alter.semitones
        self.init(diatonic: diatonic, chromatic: chromatic)
    }
    
    private func transpose(tonality: MusicNote) -> MusicNote? {
        var octaves: Int = 0
        var newDiatonic = tonality.step.diatonic + diatonic
        while newDiatonic < 0 {
            newDiatonic += 7
            octaves -= 1
        }
        while newDiatonic >= 7 {
            newDiatonic -= 7
            octaves += 1
        }
        let newStep = MusicStep.getByDiatonic(diatonic: newDiatonic)!
        var newSemitones = tonality.step.chromatic + tonality.alter.semitones + chromatic - newStep.chromatic
        newSemitones -= 12 * octaves
        guard let newAlter = MusicAlter.getBySemitones(semitones: newSemitones) else {
            return nil
        }
        return MusicNote(step: newStep, alter: newAlter)
    }
    
    func transpose(line: String) -> String {
        let acc = line.matches(of: /[A-G](?:bb?|#|x)?/).reduce(("", line.startIndex), { acc, match in
            let block = line[acc.1..<match.startIndex].replacing(/\s{2,}/, with: " ")
            let spaceCount = line.distance(from: line.startIndex, to: match.startIndex) - acc.0.count - block.count
            let space: String
            if block.last == "/" || spaceCount < 0 {
                space = ""
            } else {
                space = String(repeating: " ", count: spaceCount)
            }
            let srcNotation = String(line[match.range])
            let srcTonality = MusicNote(notation: srcNotation)!
            let dstTonality = transpose(tonality: srcTonality)
            let dstNotation = dstTonality?.notation ?? MusicNote.NOTATION_ERROR
            return (acc.0 + block + space + dstNotation, match.endIndex)
        })
        return String(acc.0) + line[acc.1...]
    }
}

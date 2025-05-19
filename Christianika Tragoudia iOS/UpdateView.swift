//
//  UpdateView.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 18-05-2025.
//

import SwiftUI


private enum ViewState {
    case CHECK
    case APPLY
    case READY([Action: [SongTitle]])
    case ERROR
    
    var canCheck: Bool {
        return switch self {
        case .CHECK:
            false
        case .APPLY:
            false
        case .READY(_):
            true
        case .ERROR:
            true
        }
    }
    
    var canApply: Bool {
        return switch self {
        case .CHECK:
            false
        case .APPLY:
            false
        case .READY(let actionMap):
            !actionMap.isEmpty
        case .ERROR:
            false
        }
    }
}


private enum Action: Int {
    case ADD
    case EDIT
    
    var title: String {
        return switch self {
        case .ADD:
            String(localized: "DownloadAdd")
        case .EDIT:
            String(localized: "DownloadEdit")
        }
    }
}


struct UpdateView: View {
    
    @State private var state: ViewState = .CHECK
    
    var body: some View {
        MainView(state: $state)
    }
}


private struct MainView: View {
    @Binding var state: ViewState
    
    var body: some View {
        ZStack {
            BackgroundView()
            switch state {
            case .CHECK:
                ProgressView()
                    .task(checkTask)
            case .APPLY:
                ProgressView()
                    .task(applyTask)
            case .READY(let actionMap):
                if actionMap.isEmpty {
                    VStack {
                        Image(systemName: "checkmark.circle")
                            .padding()
                        Text("DownloadSuccess")
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                } else {
                    readyView(actionMap: actionMap)
                }
            case .ERROR:
                VStack {
                    Image(systemName: "multiply.circle")
                        .padding()
                    Text("DownloadError")
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
        }
        .navigationTitle("Update")
        .toolbar(content: toolbarContent)
    }
    
    private func toolbarContent() -> some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Button("Check") {
                state = .CHECK
            }
            .disabled(!state.canCheck)
            Button("Download", systemImage: "square.and.arrow.down") {
                state = .APPLY
            }
            .buttonStyle(.borderedProminent)
            .labelStyle(.titleAndIcon)
            .disabled(!state.canApply)
        }
    }
    
    @Sendable
    private func checkTask() async -> Void {
        let db = TheDatabase()
        let after = Config.getUpdateTimestamp(db: db)
        if let patch = await Patch.get(after: after, full: false) {
            // old
            let oldSongMap = Song.getAllWithoutContent(db: db).reduce(into: [Int: Song](), { acc, song in
                acc[song.id] = song
            })
            let oldChordMap = Chord.getAllWithoutContent(db: db).reduce(into: [Int: Chord](), { acc, chord in
                acc[chord.id] = chord
            })
            let oldParentMap = oldChordMap.values.reduce(into: [Int: Chord](), { acc, chord in
                acc[chord.parent] = chord
            })
            let oldPairMap = oldSongMap.values.reduce(into: [Int: (Song, Chord)](), { acc, song in
                if let chord = oldParentMap[song.id] {
                    acc[song.id] = (song, chord)
                }
            })
            // new
            let newSongMap = (oldSongMap.values.filter({ song in
                patch.songIdSet.contains(song.id)
            }) + patch.songList).reduce(into: [Int: Song](), { acc, song in
                acc[song.id] = song
            })
            let newChordMap = (oldChordMap.values.filter({ chord in
                patch.chordIdSet.contains(chord.id)
            }) + patch.chordList).reduce(into: [Int: Chord](), { acc, chord in
                acc[chord.id] = chord
            })
            let newParentMap = newChordMap.values.reduce(into: [Int: Chord](), { acc, chord in
                acc[chord.parent] = chord
            })
            let newPairMap = newSongMap.values.reduce(into: [Int: (Song, Chord)](), { acc, song in
                if let chord = newParentMap[song.id] {
                    acc[song.id] = (song, chord)
                }
            })
            // run
            let actionMap = newPairMap.values.reduce(into: [Action: [SongTitle]](), { acc, newPair in
                let oldPair = oldPairMap[newPair.0.id]
                let action: Action?
                if oldPair == nil {
                    action = .ADD
                } else if oldPair!.0.modified != newPair.0.modified || oldPair!.1.modified != newPair.1.modified {
                    action = .EDIT
                } else {
                    action = nil
                }
                if action != nil {
                    if acc[action!] == nil {
                        acc[action!] = []
                    }
                    acc[action!]!.append(SongTitle(song: newPair.0))
                }
            })
            state = .READY(actionMap)
        } else {
            state = .ERROR
        }
    }
    
    @Sendable
    private func applyTask() async -> Void {
        let db = TheDatabase()
        let after = Config.getUpdateTimestamp(db: db)
        if let patch = await Patch.get(after: after, full: true) {
            // old
            let oldSongMap = Song.getAll(db: db).reduce(into: [Int: Song](), { acc, song in
                acc[song.id] = song
            })
            let oldChordMap = Chord.getAll(db: db).reduce(into: [Int: Chord](), { acc, chord in
                acc[chord.id] = chord
            })
            // ins
            let insSongList = patch.songList.filter({ song in
                oldSongMap[song.id] == nil
            })
            let insChordList = patch.chordList.filter({ chord in
                oldChordMap[chord.id] == nil
            })
            // upd
            let updSongList = patch.songList.filter({ song in
                oldSongMap[song.id] != nil
            })
            let updChordList = patch.chordList.filter({ chord in
                oldChordMap[chord.id] != nil
            })
            // del
            let delSongList = oldSongMap.values.filter({ song in
                !patch.songIdSet.contains(song.id)
            })
            let delChordList = oldChordMap.values.filter({ chord in
                !patch.chordIdSet.contains(chord.id)
            })
            // run
            Song.insert(db: db, songList: insSongList)
            SongFts.insert(db: db, ftsList: insSongList.map({ SongFts(song: $0) }))
            Song.update(db: db, songList: updSongList)
            SongFts.update(db: db, ftsList: updSongList.map({ SongFts(song: $0) }))
            Song.delete(db: db, songList: delSongList)
            SongFts.delete(db: db, ftsList: delSongList.map({ SongFts(song: $0) }))
            SongFts.optimize(db: db)
            Chord.insert(db: db, chordList: insChordList)
            Chord.update(db: db, chordList: updChordList)
            Chord.delete(db: db, chordList: delChordList)
            Config.setUpdateTimestamp(db: db, value: patch.timestamp)
            state = .READY([:])
        } else {
            state = .ERROR
        }
    }
    
    @ViewBuilder
    private func readyView(actionMap: [Action: [SongTitle]]) -> some View {
        if #available(iOS 16.0, *) {
            List {
                readyListContent(actionMap: actionMap)
            }
            .scrollContentBackground(.hidden)
        } else {
            List {
                readyListContent(actionMap: actionMap)
            }
            .listStyle(.plain)
        }
    }
    
    private func readyListContent(actionMap: [Action: [SongTitle]]) -> some View {
        ForEach(actionMap.sorted(by: { lhs, rhs in
            lhs.key.rawValue < rhs.key.rawValue
        }).map({ action, resultList in
            (action, resultList.sorted())
        }), id: \.0, content: { action, resultList in
            Section(action.title) {
                ForEach(resultList) { result in
                    VStack(alignment: .leading) {
                        Text(result.title)
                            .font(.headline)
                        if (result.title != result.excerpt) {
                            Text(result.excerpt)
                                .font(.subheadline)
                        }
                    }
                }
            }
            .listRowBackground(readyListItemBackground())
        })
    }
    
    private func readyListItemBackground() -> some View {
        Color(UIColor.secondarySystemGroupedBackground).opacity(0.5)
    }
}


#Preview("Ready") {
    let actionMap: [Action: [SongTitle]] = [
        .ADD: [
            SongTitle(id: 1, title: "Θαβώρ", excerpt: "Θ' ανεβούμε μαζί στο βουνό"),
            SongTitle(id: 2, title: "Ευωδία Χριστού", excerpt: "Στης αγάπης τον ήλιο"),
        ],
        .EDIT: [
            SongTitle(id: 3, title: "Ριζοτόμοι", excerpt: "Παντού γύρω φυτρωμένα"),
            SongTitle(id: 4, title: "Στου Παρνασσού μας", excerpt: "Στου Παρνασσού μας"),
        ],
    ]
    if #available(iOS 16.0, *) {
        NavigationStack {
            MainView(state: .constant(.READY(actionMap)))
        }
    } else {
        NavigationView {
            MainView(state: .constant(.READY(actionMap)))
        }
    }
}


#Preview("Final") {
    if #available(iOS 16.0, *) {
        NavigationStack {
            MainView(state: .constant(.READY([:])))
        }
    } else {
        NavigationView {
            MainView(state: .constant(.READY([:])))
        }
    }
}


#Preview("Error") {
    if #available(iOS 16.0, *) {
        NavigationStack {
            MainView(state: .constant(.ERROR))
        }
    } else {
        NavigationView {
            MainView(state: .constant(.ERROR))
        }
    }
}

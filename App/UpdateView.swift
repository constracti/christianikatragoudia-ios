//
//  UpdateView.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 18-05-2025.
//

import SwiftUI


private enum ViewState {
    case check
    case apply
    case ready([UpdateAction: [SongTitle]])
    case error
    
    var canCheck: Bool {
        switch self {
        case .check:
            false
        case .apply:
            false
        case .ready:
            true
        case .error:
            true
        }
    }
    
    var canApply: Bool {
        switch self {
        case .check:
            false
        case .apply:
            false
        case .ready(let actionMap):
            !actionMap.isEmpty
        case .error:
            false
        }
    }
}


enum UpdateAction: Int {
    case ADD
    case EDIT
    
    var title: String {
        switch self {
        case .ADD:
            String(localized: "DownloadAdd")
        case .EDIT:
            String(localized: "DownloadEdit")
        }
    }
}


struct UpdateView: View {
    @State private var state: ViewState
    private let isPreview: Bool
    
    static var systemImage: String {
        if #available(iOS 18, *) {
            "arrow.trianglehead.2.clockwise.rotate.90"
        } else {
            "arrow.triangle.2.circlepath"
        }
    }
    
    init() {
        self.state = .check
        self.isPreview = false
    }
    
    fileprivate init(state: ViewState) {
        self.state = state
        self.isPreview = true
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            switch state {
            case .check:
                ProgressView()
                    .task(checkTask)
            case .apply:
                ProgressView()
                    .task(applyTask)
            case .ready(let actionMap):
                if actionMap.isEmpty {
                    ThemeMessage("DownloadSuccess", systemImage: "checkmark.circle")
                        .padding(outerPadding)
                } else {
                    ReadyContent(actionMap: actionMap)
                }
            case .error:
                ThemeMessage("DownloadError", systemImage: "multiply.circle")
                    .padding(outerPadding)
            }
        }
        .navigationTitle("Update")
        .toolbar {
            ViewToolbar(state: $state)
        }
        .analyticsScreen(name: String(localized: "Update"), class: "/options/update/")
    }
    
    @Sendable
    private func checkTask() async -> Void {
        if isPreview { return }
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
            let actionMap = newPairMap.values.reduce(into: [UpdateAction: [SongTitle]](), { acc, newPair in
                let oldPair = oldPairMap[newPair.0.id]
                let action: UpdateAction?
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
            if actionMap.isEmpty {
                Config.setUpdateCheck(db: db, value: false)
            }
            state = .ready(actionMap)
        } else {
            state = .error
        }
        TheAnalytics.logUpdateCheck()
    }
    
    @Sendable
    private func applyTask() async -> Void {
        if isPreview { return }
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
            db.beginTransaction()
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
            Config.setUpdateCheck(db: db, value: false)
            db.commitTransaction()
            state = .ready([:])
        } else {
            state = .error
        }
        TheAnalytics.logUpdateApply()
    }
}


private struct ReadyContent: View {
    let actionMap: [UpdateAction: [SongTitle]]
    
    @ScaledMetric private var spacing: Double = smallMargin
    
    var body: some View {
        let tupleList = actionMap.sorted(by: { lhs, rhs in
            lhs.key.rawValue < rhs.key.rawValue
        }).map({ action, resultList in
            (action, resultList.sorted())
        })
        ScrollView {
            LazyVStack(alignment: .leading, spacing: spacing) {
                ForEach(tupleList, id: \.0) { action, resultList in
                    let title = "\(action.title) (\(resultList.count))"
                    Text(title)
                        .modifier(ThemeTitleModifier())
                    ForEach(resultList) { result in
                        ThemeResultEntry(result: result)
                    }
                }
            }
            .padding(outerPadding)
        }
    }
}


private struct ViewToolbar: ToolbarContent {
    @Binding var state: ViewState
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Button("Check", action: {
                state = .check
            })
            .disabled(!state.canCheck)
            Button("Download", systemImage: "square.and.arrow.down", action: {
                state = .apply
            })
            .buttonStyle(.borderedProminent)
            .labelStyle(.titleAndIcon)
            .disabled(!state.canApply)
        }
    }
}


#Preview("Ready") {
    NavigationStack {
        UpdateView(state: .ready(Demo.actionMap))
    }
}


#Preview("Final") {
    NavigationStack {
        UpdateView(state: .ready([:]))
    }
}


#Preview("Error") {
    NavigationStack {
        UpdateView(state: .error)
    }
}

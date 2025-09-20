//
//  SongView.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 07-05-2025.
//

import SwiftUI


private enum ViewState {
    case start(Int)
    case ready(ReadyState)
}


extension Binding<ViewState> {
    
    fileprivate func bindReadyState() -> Binding<ReadyState> {
        Binding<ReadyState>(
            get: {
                switch wrappedValue {
                case .start:
                    preconditionFailure()
                case .ready(let readyState):
                    readyState
                }
            }, set: { readyState in
                switch wrappedValue {
                case .start:
                    preconditionFailure()
                case .ready:
                    wrappedValue = .ready(readyState)
                }
            },
        )
    }
}


private struct ReadyState {
    let song: Song
    let songMeta: SongMeta
    let chord: Chord
    let chordMeta: ChordMeta
    let hiddenTonalities: Set<MusicNote>
    
    func copyWithSongMeta(songMeta: SongMeta) -> ReadyState {
        ReadyState(
            song: self.song,
            songMeta: songMeta,
            chord: self.chord,
            chordMeta: self.chordMeta,
            hiddenTonalities: self.hiddenTonalities,
        )
    }
    
    func copyWithChordMeta(chordMeta: ChordMeta) -> ReadyState {
        ReadyState(
            song: self.song,
            songMeta: self.songMeta,
            chord: self.chord,
            chordMeta: chordMeta,
            hiddenTonalities: self.hiddenTonalities,
        )
    }
}


extension Binding<ReadyState> {
    
    func bindSongMeta() -> Binding<SongMeta> {
        Binding<SongMeta>(
            get: {
                wrappedValue.songMeta
            }, set: { songMeta in
                wrappedValue = wrappedValue.copyWithSongMeta(songMeta: songMeta)
            },
        )
    }
    
    func bindChordMeta() -> Binding<ChordMeta> {
        Binding<ChordMeta>(
            get: {
                wrappedValue.chordMeta
            }, set: { chordMeta in
                wrappedValue = wrappedValue.copyWithChordMeta(chordMeta: chordMeta)
            },
        )
    }
}


struct SongView: View {
    @State private var viewState: ViewState
    private let isPreview: Bool
    
    init(id: Int) {
        self.viewState = .start(id)
        self.isPreview = false
    }
    
    fileprivate init(viewState: ViewState) {
        self.viewState = viewState
        self.isPreview = true
    }
    
    var body: some View {
        switch viewState {
        case .start(let id):
            ZStack {
                BackgroundView()
                ProgressView()
            }
            .task {
                if isPreview { return }
                let db = TheDatabase()
                guard let song = Song.getById(db: db, id: id) else { return }
                guard let chord = Chord.getByParent(db: db, parent: id) else { return }
                let visited = Date.now
                    .formatted(.iso8601.dateTimeSeparator(.space))
                    .replacing("Z", with: "")
                let songMeta = SongMeta.getById(db: db, id: id).copyWithVisited(visited: visited)
                songMeta.upsert(db: db)
                let chordMeta = ChordMeta.getById(db: db, id: chord.id)
                let hiddenTonalities = Config.getHiddenTonalities(db: db) ?? MusicNote.ENHARMONIC_TONALITIES
                let readyState = ReadyState(
                    song: song,
                    songMeta: songMeta,
                    chord: chord,
                    chordMeta: chordMeta,
                    hiddenTonalities: hiddenTonalities,
                )
                viewState = .ready(readyState)
            }
        case .ready(let readyState):
            MainView(
                song: readyState.song,
                songMeta: $viewState.bindReadyState().bindSongMeta(),
                chord: readyState.chord,
                chordMeta: $viewState.bindReadyState().bindChordMeta(),
                hiddenTonalities: readyState.hiddenTonalities,
                isPreview: isPreview,
            )
        }
    }
}


extension Binding<SongMeta> {
    
    func bindZoom(isPreview: Bool) -> Binding<Double> {
        Binding<Double>(
            get: {
                wrappedValue.zoom
            },
            set: { zoom in
                wrappedValue = wrappedValue.copyWithZoom(zoom: zoom)
                if isPreview { return }
                wrappedValue.upsert(db: TheDatabase())
            },
        )
    }
    
    func bindStarred(isPreview: Bool) -> Binding<Bool> {
        Binding<Bool>(
            get: {
                wrappedValue.starred
            },
            set: { starred in
                wrappedValue = wrappedValue.copyWithStarred(starred: starred)
                if isPreview { return }
                wrappedValue.upsert(db: TheDatabase())
            },
        )
    }
}


extension Binding<ChordMeta> {

    func bindTonality(isPreview: Bool) -> Binding<MusicNote?> {
        Binding<MusicNote?>(
            get: {
                wrappedValue.tonality
            },
            set: { tonality in
                wrappedValue = wrappedValue.copyWithTonality(tonality: tonality)
                if isPreview { return }
                wrappedValue.upsert(db: TheDatabase())
            },
        )
    }
    
    func bindZoom(isPreview: Bool) -> Binding<Double> {
        Binding<Double>(
            get: {
                wrappedValue.zoom
            },
            set: { zoom in
                wrappedValue = wrappedValue.copyWithZoom(zoom: zoom)
                if isPreview { return }
                wrappedValue.upsert(db: TheDatabase())
            },
        )
    }
}


private struct MainView: View {
    let song: Song
    @Binding var songMeta: SongMeta
    let chord: Chord
    @Binding var chordMeta: ChordMeta
    let hiddenTonalities: Set<MusicNote>
    let isPreview: Bool

    @State private var infoVisible: Bool = false
    
    var body: some View {
        ZStack {
            BackgroundView()
            if let tonality = chordMeta.tonality {
                ChordsView(chord: chord, tonality: tonality, zoom: chordMeta.zoom)
            } else {
                LyricsView(song: song, zoom: songMeta.zoom)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            MainToolbar(
                song: song,
                defaultTonality: chord.tonality,
                hiddenTonalities: hiddenTonalities,
                starred: $songMeta.bindStarred(isPreview: isPreview),
                tonality: $chordMeta.bindTonality(isPreview: isPreview),
                zoom: chordMeta.tonality == nil ? $songMeta.bindZoom(isPreview: isPreview) : $chordMeta.bindZoom(isPreview: isPreview),
                infoVisible: $infoVisible,
            )
        }
        .alert(song.title, isPresented: $infoVisible, presenting: song, actions: { song in
        }, message: { song in
            Text(song.excerpt)
        })
        .analyticsScreen(
            name: song.title,
            class: song.permalink.replacing(WebApp.homeString, with: "/"),
        )
    }
}


private struct LyricsView: View {
    let song: Song
    let zoom: Double
    
    @ScaledMetric private var spacing: Double = largeMargin
    @ScaledMetric private var fontSize: Double = bodyFontSize

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: spacing) {
                let paragraphList = song.content.split(
                    separator: /(?:\r\n|\r|\n){2,}/,
                )
                // TODO separate paragraphs in view by native newline
                ForEach(Array(paragraphList.enumerated()), id: \.offset) { _, html in
                    if html == "<hr />" {
                        Divider()
                    } else if let rich = try? AttributedString(
                        markdown: String(html)
                            .replacing("*", with: "\\*")
                            .replacing(/<\/?(?:i|em)>/, with: "*"),
                        options: AttributedString.MarkdownParsingOptions(
                            interpretedSyntax: .inlineOnly,
                        ),
                    ) {
                        Text(rich)
                    } else {
                        Text(html)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .font(.system(size: fontSize * zoom))
            .padding(outerPadding)
        }
    }
}


private struct ChordsView: View {
    let chord: Chord
    let tonality: MusicNote
    let zoom: Double
    
    @ScaledMetric private var fontSize: Double = bodyFontSize
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView([.horizontal, .vertical]) {
                VStack(alignment: .leading) {
                    // TODO use markdown
                    let interval = MusicInterval(src: chord.tonality, dst: tonality)
                    let lineList = chord.content.split(
                        separator: /\r\n|\r|\n/,
                        omittingEmptySubsequences: false,
                    )
                    ForEach(Array(lineList.enumerated()), id: \.offset) { _, line in
                        if ChordsView.isChordLine(line: String(line)) {
                            Text(interval.transpose(line: String(line)))
                                .fontWeight(.bold)
                        } else {
                            Text(line)
                        }
                    }
                }
                .frame(
                    minWidth: geometry.size.width,
                    minHeight: geometry.size.height,
                    alignment: .topLeading,
                )
                .padding(outerPadding)
            }
        }
        .font(.system(size: fontSize * zoom, design: .monospaced))
    }
    
    private static func isChordLine(line: String) -> Bool {
        if line.isEmpty {
            return false
        }
        let whitespaces = line.filter { return $0.isWhitespace }.count
        let characters = line.count
        return Double(whitespaces) / Double(characters) >= 0.5
    }
}


private struct MainToolbar: ToolbarContent {
    let song: Song
    let defaultTonality: MusicNote
    let hiddenTonalities: Set<MusicNote>
    @Binding var starred: Bool
    @Binding var tonality: MusicNote?
    @Binding var zoom: Double
    @Binding var infoVisible: Bool
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(song.title)
                .lineLimit(2)
                .font(.headline)
        }
        ToolbarItem(placement: .topBarTrailing) {
            if starred {
                Button(action: {
                    starred = false
                }) {
                    Image(systemName: "star.fill")
                }
            } else {
                Button(action: {
                    starred = true
                }, label: {
                    Image(systemName: "star")
                })
            }
        }
        ToolbarItemGroup(placement: .bottomBar) {
            TonalityMenu(
                defaultTonality: defaultTonality,
                hiddenTonalities: hiddenTonalities,
                tonality: $tonality,
            )
            Spacer()
            Button("FontSizeDecrease", systemImage: "textformat.size.smaller", action: {
                zoom *= pow(2.0, -0.1)
            })
            .disabled(zoom <= pow(2.0, -2.0))
            Button("FontSizeIncrease", systemImage: "textformat.size.larger", action: {
                zoom *= pow(2.0, +0.1)
            })
            .disabled(zoom >= pow(2.0, +2.0))
            OptionsMenu(
                song: song,
                defaultTonality: defaultTonality,
                tonality: $tonality,
                zoom: $zoom,
                infoVisible: $infoVisible,
            )
        }
    }
}


private struct TonalityMenu: View {
    let defaultTonality: MusicNote
    let hiddenTonalities: Set<MusicNote>
    @Binding var tonality: MusicNote?
    
    var body: some View {
        Menu(content: {
            Picker(selection: $tonality, content: {
                var tonalityList: [MusicNote?] = MusicNote.TONALITIES.filter({ tonality in
                    !hiddenTonalities.contains(tonality)
                })
                let _ = tonalityList.insert(nil, at: 0)
                ForEach(tonalityList, id: \.self) { tonality in
                    let text = tonality.map({ tonality in
                        let text = tonality.notation
                        if tonality == defaultTonality {
                            return text.appending(" (" + String(localized: "TonalityDefault") + ")")
                        }
                        return text
                    }) ?? String(localized: "TonalityNull")
                    Text(text)
                }
            }, label: {
                EmptyView()
            })
        }, label: {
            let text = String(localized: "TonalitySelect")
                .appending(tonality.map({ tonality in
                    ": " + tonality.notation
                }) ?? "")
            Label(text, systemImage: "chevron.up.chevron.down")
                .labelStyle(.titleAndIcon)
        })
        .menuStyle(.button)
        .menuOrder(.fixed)
        .buttonStyle(.bordered)
    }
}


private struct OptionsMenu: View {
    let song: Song
    let defaultTonality: MusicNote
    @Binding var tonality: MusicNote?
    @Binding var zoom: Double
    @Binding var infoVisible: Bool
    
    var body: some View {
        Menu("Options", systemImage: "ellipsis.circle", content: {
            Button("Information", systemImage: "info.circle", action: {
                infoVisible = true
            })
            if let url = URL(string: song.permalink) {
                Link(destination: url, label: {
                    Label("OpenInBrowser", systemImage: "link")
                })
                ShareLink("Share", item: url)
            }
            Button("TonalityHide", systemImage: "note.text", action: {
                tonality = nil
            })
            .disabled(tonality == nil)
            Button("TonalityReset", systemImage: "music.note.list", action: {
                tonality = defaultTonality
            })
            .disabled(tonality == defaultTonality)
            Button("FontSizeReset", systemImage: "textformat.size", action: {
                zoom = pow(2.0, 0.0)
            })
            .disabled(zoom == pow(2.0, 0.0))
        })
        .menuOrder(.fixed)
    }
}


#Preview("Lyrics") {
    NavigationStack {
        SongView(viewState: .ready(ReadyState(
            song: Demo.song,
            songMeta: Demo.songMeta,
            chord: Demo.chord,
            chordMeta: Demo.chordMeta,
            hiddenTonalities: MusicNote.ENHARMONIC_TONALITIES,
        )))
    }
}


#Preview("Chords") {
    NavigationStack {
        SongView(viewState: .ready(ReadyState(
            song: Demo.song,
            songMeta: Demo.songMeta.copyWithStarred(starred: true),
            chord: Demo.chord,
            chordMeta: Demo.chordMeta.copyWithTonality(tonality: Demo.chord.tonality),
            hiddenTonalities: MusicNote.ENHARMONIC_TONALITIES,
        )))
    }
}

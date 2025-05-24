//
//  SongView.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 07-05-2025.
//

import SwiftUI


struct SongView: View {
    let id: Int
    
    @State private var song: Song? = nil
    @State private var songMeta: SongMeta? = nil
    @State private var chord: Chord? = nil
    @State private var chordMeta: ChordMeta? = nil
    @State private var hiddenTonalities: Set<MusicNote>? = nil
    @State private var loading: Bool = true
    
    var body: some View {
        if loading {
            ZStack {
                BackgroundView()
                ProgressView()
            }
            .task {
                let db = TheDatabase()
                song = Song.getById(db: db, id: id)
                guard let song else { return }
                chord = Chord.getByParent(db: db, parent: id)
                guard let chord else { return }
                let visited = Date.now.formatted(.iso8601.dateTimeSeparator(.space)).replacingOccurrences(of: "Z", with: "")
                songMeta = SongMeta.getById(db: db, id: song.id).copyWithVisited(visited: visited)
                songMeta!.upsert(db: db)
                chordMeta = ChordMeta.getById(db: db, id: chord.id)
                hiddenTonalities = Config.getHiddenTonalities(db: db) ?? MusicNote.ENHARMONIC_TONALITIES
                loading = false
            }
        } else {
            SongMain(
                song: song!,
                songMeta: Binding($songMeta)!,
                chord: chord!,
                chordMeta: Binding($chordMeta)!,
                hiddenTonalities: hiddenTonalities!,
            )
        }
    }
}


extension Binding<SongMeta> {
    
    func bindZoom() -> Binding<Double> {
        Binding<Double>(
            get: {
                return self.wrappedValue.zoom
            },
            set: { zoom in
                self.wrappedValue = self.wrappedValue.copyWithZoom(zoom: zoom)
                self.wrappedValue.upsert(db: TheDatabase())
            },
        )
    }
    
    func bindStarred() -> Binding<Bool> {
        Binding<Bool>(
            get: {
                return self.wrappedValue.starred
            },
            set: { starred in
                self.wrappedValue = self.wrappedValue.copyWithStarred(starred: starred)
                self.wrappedValue.upsert(db: TheDatabase())
            },
        )
    }
}


extension Binding<ChordMeta> {

    func bindTonality() -> Binding<MusicNote?> {
        Binding<MusicNote?>(
            get: {
                return self.wrappedValue.tonality
            },
            set: { tonality in
                self.wrappedValue = self.wrappedValue.copyWithTonality(tonality: tonality)
                self.wrappedValue.upsert(db: TheDatabase())
            },
        )
    }
    
    func bindZoom() -> Binding<Double> {
        Binding<Double>(
            get: {
                return self.wrappedValue.zoom
            },
            set: { zoom in
                self.wrappedValue = self.wrappedValue.copyWithZoom(zoom: zoom)
                self.wrappedValue.upsert(db: TheDatabase())
            },
        )
    }
}


private struct SongMain: View {
    let song: Song
    @Binding var songMeta: SongMeta
    let chord: Chord
    @Binding var chordMeta: ChordMeta
    let hiddenTonalities: Set<MusicNote>

    @State private var infoVisible: Bool = false
    
    var body: some View {
        ZStack {
            BackgroundView()
            if chordMeta.tonality == nil {
                SongLyrics(song: song, zoom: songMeta.zoom)
            } else {
                SongChords(chord: chord, tonality: chordMeta.tonality!, zoom: chordMeta.zoom)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            SongToolbar(
                song: song,
                defaultTonality: chord.tonality,
                hiddenTonalities: hiddenTonalities,
                starred: $songMeta.bindStarred(),
                tonality: $chordMeta.bindTonality(),
                zoom: chordMeta.tonality == nil ? $songMeta.bindZoom() : $chordMeta.bindZoom(),
                infoVisible: $infoVisible,
            )
        }
        .alert(song.title, isPresented: $infoVisible, presenting: song, actions: { song in
        }, message: { song in
            Text(song.excerpt)
        })
    }
}


private struct SongLyrics: View {
    let song: Song
    let zoom: Double

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24.0 * zoom) {
                if #available(iOS 16.0, *) {
                    ForEach(Array(song.content.split(separator: /(?:\r\n|\r|\n){2,}/).enumerated()), id: \.offset) { _, html in
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
                } else {
                    ForEach(Array(song.content.replacingOccurrences(of: "\r\n|\r|\n", with: "\n", options: .regularExpression).components(separatedBy: "\n\n").enumerated()), id: \.offset) { _, html in
                        if html == "<hr />" {
                            Divider()
                        } else if let rich = try? AttributedString(
                            markdown: String(html)
                                .replacingOccurrences(of: "*", with: "\\*")
                                .replacingOccurrences(of: "</?(?:i|em)>", with: "*", options: .regularExpression),
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
            }
            .padding()
            // .navigationTitle(song.title)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .font(.system(size: 16.0 * zoom))
        }
    }
}


private struct SongChords: View {
    let chord: Chord
    let tonality: MusicNote
    let zoom: Double

    var body: some View {
        GeometryReader { geometry in
            ScrollView([.horizontal, .vertical]) {
                VStack {
                    VStack(alignment: .leading) {
                        let interval = MusicInterval(src: chord.tonality, dst: tonality)
                        if #available(iOS 16.0, *) {
                            ForEach(Array(chord.content.split(separator: /\r\n|\r|\n/, omittingEmptySubsequences: false).enumerated()), id: \.offset) { _, line in
                                if SongChords.isChordLine(line: String(line)) {
                                    Text(interval.transpose(line: String(line)))
                                        .fontWeight(.bold)
                                } else {
                                    Text(line)
                                }
                            }
                        } else {
                            ForEach(Array(chord.content.replacingOccurrences(of: "\r\n|\r|\n", with: "\n", options: .regularExpression).components(separatedBy: "\n").enumerated()), id:\.offset) { _, line in
                                if SongChords.isChordLine(line: line) {
                                    Text(interval.transpose(line: line))
                                        .fontWeight(.bold)
                                } else {
                                    Text(line)
                                }
                            }
                        }
                    }
                    .padding()
                }
                .frame(minWidth: geometry.size.width, minHeight: geometry.size.height, alignment: .topLeading)
            }
        }
        .font(.system(size: 16.0 * zoom, design: .monospaced))
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


private struct SongToolbar: ToolbarContent {
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
            if #available(iOS 16.0, *) {
                Menu(content: {
                    Picker("TonalitySelect", selection: $tonality) {
                        ForEach(tonalityMenuList(), id: \.self) { tonality in
                            Text(tonalityMenuItem(tonality: tonality))
                        }
                    }
                }, label: {
                    Label(tonalityMenuText(), systemImage: "chevron.up.chevron.down").labelStyle(.titleAndIcon)
                })
                .menuStyle(.button)
                .menuOrder(.fixed)
                .buttonStyle(.bordered)
            } else {
                Menu(tonalityMenuText()) {
                    Picker("TonalitySelect", selection: $tonality) {
                        ForEach(tonalityMenuList().reversed(), id: \.self) { tonality in
                            Text(tonalityMenuItem(tonality: tonality))
                        }
                    }
                }
            }
            Spacer()
            Button("FontSizeDecrease", systemImage: "textformat.size.smaller", action: {
                zoom *= pow(2.0, -0.1)
            })
            .disabled(zoom <= pow(2.0, -2.0))
            Button("FontSizeIncrease", systemImage: "textformat.size.larger", action: {
                zoom *= pow(2.0, +0.1)
            })
            .disabled(zoom >= pow(2.0, +2.0))
            if #available(iOS 16.0, *) {
                Menu("SongOptions", systemImage: "ellipsis.circle", content: optionsMenuContent)
                    .menuOrder(.fixed)
            } else {
                Menu("SongOptions", systemImage: "ellipsis.circle", content: optionsMenuContent)
            }
        }
    }
    
    private func tonalityMenuText() -> String {
        var text: String = String(localized: "TonalitySelect")
        if tonality != nil {
            text += ": " + tonality!.notation
        }
        return text
    }
    
    private func tonalityMenuList() -> Array<MusicNote?> {
        var tonalities: Array<MusicNote?> = MusicNote.TONALITIES.filter { tonality in
            !hiddenTonalities.contains(tonality)
        }
        tonalities.insert(nil, at: 0)
        return tonalities
    }
    
    private func tonalityMenuItem(tonality: MusicNote?) -> String {
        guard let tonality else { return String(localized: "TonalityNull") }
        var text: String = tonality.notation
        if tonality == defaultTonality {
            text += " (" + String(localized: "TonalityDefault") + ")"
        }
        return text
    }
    
    @ViewBuilder
    private func optionsMenuContent() -> some View {
        Button("Information", systemImage: "info.circle", action: {
            infoVisible = true
        })
        if let url = URL(string: song.permalink) {
            Link(destination: url, label: {
                Label("OpenInBrowser", systemImage: "link")
            })
            if #available(iOS 16.0, *) {
                ShareLink("Share", item: url)
            }
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
    }
}


#Preview {
    let song = Song(
        id: 1,
        date: "2022",
        content: """
            Θ' ανεβούμε μαζί στο βουνό,
            στο βουνό το ψηλό, το μεγάλο.
            Μπρος εσύ, πίσω εγώ κι αρχινώ
            της αυγής το τραγούδι να ψάλλω.
            
            <i>Μπρος εσύ, πίσω εγώ και γοργοί
            στου Θαβώρ τις κορφές θ' ανεβούμε
            και μακριά απ' την πολύβουη γη
            άλλων κόσμων το φως θα χαρούμε.</i>
            
            Πόσο λάμπει η θεϊκιά σου μορφή,
            πώς αστράφτει ο λευκός σου χιτώνας.
            Τρεις σκηνές να στηθούν στην κορφή
            κι ας τη δέρνει ο βοριάς κι ο χειμώνας.

            <i>Μπρος εσύ, πίσω εγώ και γοργοί…</i>
            """,
        title: "Θαβώρ",
        excerpt: """
            Θ' ανεβούμε μαζί στο βουνό

            στίχοι: Γ. Βερίτης
            μουσική: Α. Χατζηαποστόλου
            """,
        modified: "2022",
        permalink: "https://christianikatragoudia.gr/songs/thavor-tha-anevoume-mazi/",
    )
    let songMeta = SongMeta(id: 1)
    let chord = Chord(
        id: 7566,
        date: "2022",
        modified: "2022",
        parent: 1,
        content: """
            Gm    EbΔ7  Gm    EbΔ7  

                  Gm                Dm
            Θ' ανεβούμε μαζί στο βουνό,
                   Eb               Bb
            στο βουνό το ψηλό, το μεγάλο.
                   Gm                  Cm
            Μπρος εσύ, πίσω εγώ κι αρχινώ
                            Gm       D Gm
            της αυγής το τραγούδι να ψάλλω.

            G  D  

                   G                  Bm
            Μπρος εσύ, πίσω εγώ και γοργοί
                   C                    G
            στου Θαβώρ τις κορφές θ' ανεβούμε
                  C              D      G
            και μακριά απ' την πολύβουη γη
                  Em        C        D  G   D
            άλλων κόσμων το φως θα χαρούμε.

            Gm    EbΔ7  Gm    EbΔ7  

                 Gm                    Dm
            Πόσο λάμπει η θεϊκιά σου μορφή,
                 Eb                      Bb
            πώς αστράφτει ο λευκός σου χιτώνας.
                     Gm                    Cm
            Τρεις σκηνές να στηθούν στην κορφή
                                Gm           D Gm
            κι ας τη δέρνει ο βοριάς κι ο χειμώνας.

            G  D  


            Μπρος εσύ, πίσω εγώ και γοργοί…
            """,
        tonality: MusicNote(notation: "G")!,
    )
    let chordMeta = ChordMeta(id: 7566)
    if #available(iOS 16.0, *) {
        NavigationStack {
            SongMain(
                song: song,
                songMeta: .constant(songMeta),
                chord: chord,
                chordMeta: .constant(chordMeta),
                hiddenTonalities: MusicNote.ENHARMONIC_TONALITIES,
            )
        }
    } else {
        NavigationView {
            SongMain(
                song: song,
                songMeta: .constant(songMeta),
                chord: chord,
                chordMeta: .constant(chordMeta),
                hiddenTonalities: MusicNote.ENHARMONIC_TONALITIES,
            )
        }
    }
}

//
//  Common.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 24-05-2025.
//

import SwiftUI


struct HomeToolbarContent: ToolbarContent {
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            NavigationLink(destination: {
                OptionsView()
            }, label: {
                Label("Options", systemImage: "gearshape")
            })
        }
    }
}


struct ResultRow: View {
    let result: SongTitle
    
    var body: some View {
        NavigationLink {
            SongView(id: result.id)
        } label: {
            VStack(alignment: .leading) {
                Text(result.title)
                    .font(.headline)
                if (result.title != result.excerpt) {
                    Text(result.excerpt)
                        .font(.subheadline)
                }
            }
        }
        .listRowBackground(ListBackground())
    }
}


// TODO change color on tap

struct ListBackground: View {
    
    var body: some View {
        Color(UIColor.secondarySystemGroupedBackground).opacity(0.5)
    }
}


class Demo {
    
    static let resultList: [SongTitle] = [
        SongTitle(id: 1, title: "Θαβώρ", excerpt: "Θ' ανεβούμε μαζί στο βουνό"),
        SongTitle(id: 14, title: "Ευωδία Χριστού", excerpt: "Στης αγάπης τον ήλιο"),
        SongTitle(id: 16, title: "Ριζοτόμοι", excerpt: "Παντού γύρω φυτρωμένα"),
        SongTitle(id: 18, title: "Στου Παρνασσού μας", excerpt: "Στου Παρνασσού μας"),
        SongTitle(id: 20, title: "Πολιτεία αγάπης", excerpt: "Υψώστε λάβαρο σταυρού στον Παρνασσό"),
        SongTitle(id: 22, title: "Χαρωπές φωνές", excerpt: "Όμορφη η ζωή μας, δίχως φόβο"),
        SongTitle(id: 24, title: "Μη δειλιάζεις", excerpt: "Κίνησε τώρα μαχητή"),
        SongTitle(id: 27, title: "Στου Χριστού μας το λιμάνι", excerpt: "Στου Χριστού μας το λιμάνι"),
        SongTitle(id: 29, title: "Γη της επαγγελίας", excerpt: "Βγήκαν απ' τη χώρα της δουλείας"),
        SongTitle(id: 31, title: "Ισχυροί", excerpt: "Ισχυροί στρατιώτες"),
        SongTitle(id: 33, title: "Σύναιμοι", excerpt: "Νιώθω μονάχος σαν πέφτει ο ήλιος"),
        SongTitle(id: 35, title: "Πολύκαρποι", excerpt: "Άγονη γη διψά πολύ"),
        SongTitle(id: 37, title: "Μαζί με το Χριστό μου", excerpt: "Μαζί με το Χριστό μου"),
        SongTitle(id: 39, title: "Γρηγορείτε", excerpt: "Όταν την ψυχή ταλαιπωρεί"),
        SongTitle(id: 41, title: "Είν' ο δρόμος ανοιχτός", excerpt: "Είν' ο δρόμος ανοιχτός"),
        SongTitle(id: 43, title: "Σκυταλοδρόμοι", excerpt: "Σε πίκραναν πολλοί"),
    ]
    
    static let song: Song = Song(
        id: 1,
        date: "2022-01-10",
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
        modified: "2022-01-10",
        permalink: "https://christianikatragoudia.gr/songs/thavor-tha-anevoume-mazi/",
    )
    
    static let songMeta = SongMeta(id: 1)
    
    static let chord = Chord(
        id: 7566,
        date: "2024-03-11",
        modified: "2024-03-11",
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
    
    static let chordMeta = ChordMeta(id: 7566)
    
    static let actionMap: [UpdateAction: [SongTitle]] = [
        .ADD: Array(Demo.resultList[0..<2]),
        .EDIT: Array(Demo.resultList[2..<4]),
    ]
}

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


let demoResultList: [SongTitle] = [
    SongTitle(id: 1, title: "Θαβώρ", excerpt: "Θ' ανεβούμε μαζί στο βουνό"),
    SongTitle(id: 2, title: "Ευωδία Χριστού", excerpt: "Στης αγάπης τον ήλιο"),
    SongTitle(id: 3, title: "Ριζοτόμοι", excerpt: "Παντού γύρω φυτρωμένα"),
    SongTitle(id: 4, title: "Στου Παρνασσού μας", excerpt: "Στου Παρνασσού μας"),
    SongTitle(id: 5, title: "Πολιτεία αγάπης", excerpt: "Υψώστε λάβαρο σταυρού στον Παρνασσό"),
    SongTitle(id: 6, title: "Χαρωπές φωνές", excerpt: "Όμορφη η ζωή μας, δίχως φόβο"),
    SongTitle(id: 7, title: "Μη δειλιάζεις", excerpt: "Κίνησε τώρα μαχητή"),
    SongTitle(id: 8, title: "Στου Χριστού μας το λιμάνι", excerpt: "Στου Χριστού μας το λιμάνι"),
    SongTitle(id: 9, title: "Γη της επαγγελίας", excerpt: "Βγήκαν απ' τη χώρα της δουλείας"),
    SongTitle(id: 10, title: "Ισχυροί", excerpt: "Ισχυροί στρατιώτες"),
    SongTitle(id: 11, title: "Σύναιμοι", excerpt: "Νιώθω μονάχος σαν πέφτει ο ήλιος"),
    SongTitle(id: 12, title: "Πολύκαρποι", excerpt: "Άγονη γη διψά πολύ"),
    SongTitle(id: 13, title: "Μαζί με το Χριστό μου", excerpt: "Μαζί με το Χριστό μου"),
    SongTitle(id: 14, title: "Γρηγορείτε", excerpt: "Όταν την ψυχή ταλαιπωρεί"),
    SongTitle(id: 15, title: "Είν' ο δρόμος ανοιχτός", excerpt: "Είν' ο δρόμος ανοιχτός"),
    SongTitle(id: 16, title: "Σκυταλοδρόμοι", excerpt: "Σε πίκραναν πολλοί"),
]

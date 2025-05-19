//
//  SearchView.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 03-05-2025.
//

import SwiftUI


// TODO favorites and recent as filter
// https://developer.apple.com/tutorials/swiftui/handling-user-input


struct SearchView: View {

    var body: some View {
        MainView()
    }
}


private struct MainView: View {
    @State var query: String = ""
    @State var resultList: [SongTitle]? = nil
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack(root: navigationContent)
        } else {
            NavigationView(content: navigationContent)
        }
    }
    
    private func navigationContent() -> some View {
        ZStack {
            BackgroundView()
            if resultList == nil {
                ProgressView()
                    .task(searchTask)
            } else {
                list()
                    .task(id: query, searchTask)
            }
        }
        .navigationTitle("Search")
        .toolbar(content: toolbarContent)
    }
    
    @Sendable
    private func searchTask() async -> Void {
        if query.isEmpty {
            resultList = SongTitle.getAll(db: TheDatabase())
        } else {
            let fullTextQuery = SongFts
                .tokenize(inString: query)
                .components(separatedBy: " ")
                .map { "\"\($0)\" OR \"\($0)*\""}
                .joined(separator: " OR ")
            resultList = SongMatch
                .getByQuery(db: TheDatabase(), query: fullTextQuery)
                .map { SongTitle(songMatch: $0) }
        }
    }

    @ViewBuilder
    private func list() -> some View {
        if #available(iOS 16.0, *) {
            List(resultList!) { result in
                listItem(result: result)
            }
            .scrollContentBackground(.hidden)
            .searchable(text: $query, prompt: "Search")
        } else {
            List(resultList!) { result in
                listItem(result: result)
            }
            .listStyle(.plain)
            .searchable(text: $query, prompt: "Search")
        }
    }
    
    @ViewBuilder
    private func listItem(result: SongTitle) -> some View {
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
        .listRowBackground(listItemBackground())
    }
    
    private func listItemBackground() -> some View {
        Color(UIColor.secondarySystemGroupedBackground).opacity(0.5)
    }
    
    private func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            NavigationLink(destination: {
                OptionsView()
            }, label: {
                Label("Options", systemImage: "gearshape")
            })
        }
    }
}


#Preview {
    let query = ""
    let resultList = [
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
    MainView(query: query, resultList: resultList)
}

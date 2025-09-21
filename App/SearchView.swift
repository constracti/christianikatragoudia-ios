//
//  SearchView.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 21-09-2025.
//

import SwiftUI


private struct ViewState {
    let query: String
    let resultList: [SongTitle]
    
    init() {
        self.query = ""
        self.resultList = []
    }

    init(query: String, resultList: [SongTitle]) {
        self.query = query
        self.resultList = resultList
    }

    init(db: TheDatabase, query: String) {
        self.query = query
        self.resultList = SongMatch
            .getByQuery(db: db, query: query)
            .map { SongTitle(songMatch: $0) }
    }
}


extension Binding<ViewState> {

    func bindQuery(isPreview: Bool) -> Binding<String> {
        Binding<String>(
            get: {
                wrappedValue.query
            },
            set: { query in
                if query == wrappedValue.query { return }
                if isPreview { return }
                wrappedValue = ViewState(db: TheDatabase(), query: query)
            },
        )
    }
}

struct SearchView: View {
    
    @State private var viewState: ViewState
    private let isPreview: Bool
    
    @ScaledMetric private var spacing: Double = smallMargin
    
    @FocusState var focus: Bool
    
    init(isPreview: Bool) {
        self.viewState = ViewState()
        self.isPreview = isPreview
    }
    
    fileprivate init(viewState: ViewState) {
        self.viewState = viewState
        self.isPreview = true
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            VStack(spacing: spacing) {
                HStack(spacing: spacing) {
                    TextField("Search", text: $viewState.bindQuery(isPreview: isPreview))
                        .focused($focus)
                        .autocorrectionDisabled()
                        .onAppear {
                            focus = true
                        }
                    Button(action: {
                        viewState = ViewState()
                    }, label: {
                        Image(systemName: "multiply")
                    })
                    .disabled(viewState.query.isEmpty)
                }
                .padding(spacing)
                .background(.backgroundDefault)
                .clipShape(RoundedRectangle(cornerRadius: spacing))
                ScrollView {
                    LazyVStack(spacing: spacing) {
                        ForEach(viewState.resultList) { result in
                            ThemeResultButton(result: result, isPreview: isPreview)
                        }
                    }
                }
            }
            .padding(outerPadding)
        }
        .navigationTitle("Search")
        .analyticsScreen(name: String(localized: "Search"), class: "/search/")
    }
}


#Preview {
    NavigationStack {
        SearchView(viewState: ViewState(query: "", resultList: Demo.resultList))
    }
}

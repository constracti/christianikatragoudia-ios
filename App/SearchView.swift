//
//  SearchView.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 03-05-2025.
//

import SwiftUI


struct SearchView: View {
    
    @State private var state: SearchState?
    private let isPreview: Bool
    
    @ScaledMetric private var spacing: Double = smallMargin
    
    init() {
        self.state = nil
        self.isPreview = false
    }
    
    fileprivate init(state: SearchState?) {
        self.state = state
        self.isPreview = true
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            if state == nil {
                ProgressView()
                    .task {
                        if isPreview { return }
                        let db = TheDatabase()
                        state = SearchState(
                            db: db,
                            query: "",
                            updateCheck: SearchState.cachedUpdateCheck(db: db),
                        )
                    }
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: spacing) {
                        if state!.query.isEmpty {
                            DestinationsSection(
                                updateCheck: state!.updateCheck,
                                isPreview: isPreview,
                            )
                        }
                        Text("Results")
                            .modifier(ThemeTitleModifier())
                        ForEach(state!.resultList) { result in
                            ThemeResultButton(result: result, isPreview: isPreview)
                        }
                    }
                    .padding(outerPadding)
                }
                .searchable(text: $state.bindQuery(isPreview: isPreview), prompt: "Search")
                .task {
                    if isPreview { return }
                    let db = TheDatabase()
                    let updateCheck = SearchState.cachedUpdateCheck(db: db)
                    state = SearchState(
                        db: db,
                        query: state!.query,
                        updateCheck: updateCheck,
                    )
                    if updateCheck { return }
                    if await !SearchState.serverUpdateCheck(db: db) { return }
                    Config.setUpdateCheck(db: db, value: true)
                    state = state!.copyWithUpdateCheck(updateCheck: true)
                }
            }
        }
        .navigationTitle("AppName")
        .toolbar {
            MainToolbarContent(isPreview: isPreview)
        }
        .analyticsScreen(name: String(localized: "Search"), class: "/search/")
    }
}


private struct DestinationsSection: View {
    let updateCheck: Bool
    let isPreview: Bool
    
    var body: some View {
        Text("Destinations")
            .modifier(ThemeTitleModifier())
        NavigationLink(destination: {
            if isPreview {
                EmptyView()
            } else {
                StarredView()
            }
        }, label: {
            HStack {
                Image(systemName: StarredView.systemImage)
                Text("Starred")
                Spacer()
                Image(systemName: "chevron.right")
            }
        })
        .buttonStyle(ThemeButtonStyle())
        NavigationLink(destination: {
            if isPreview {
                EmptyView()
            } else {
                RecentView()
            }
        }, label: {
            HStack {
                Image(systemName: RecentView.systemImage)
                Text("Recent")
                Spacer()
                Image(systemName: "chevron.right")
            }
        })
        .buttonStyle(ThemeButtonStyle())
        if updateCheck {
            NavigationLink(destination: {
                if isPreview {
                    EmptyView()
                } else {
                    UpdateView()
                }
            }, label: {
                HStack {
                    Label("Update", systemImage: UpdateView.systemImage)
                    Spacer()
                    Image(systemName: "smallcircle.filled.circle.fill")
                        .foregroundStyle(.badge)
                    Image(systemName: "chevron.right")
                }
            })
            .buttonStyle(ThemeButtonStyle())
        }
    }
}


#Preview {
    NavigationStack {
        SearchView(state: SearchState(
            query: "",
            resultList: Demo.resultList,
            updateCheck: true,
        ))
    }
}

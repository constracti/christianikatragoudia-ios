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
                List {
                    if state!.query.isEmpty {
                        DestinationsSection(
                            updateCheck: state!.updateCheck,
                            isPreview: isPreview,
                        )
                    }
                    Section("Results") {
                        ForEach(state!.resultList) { result in
                            ResultRow(result: result, isPreview: isPreview)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
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
            HomeToolbarContent(isPreview: isPreview)
        }
        .analyticsScreen(name: String(localized: "Search"), class: "/search/")
    }
}


private struct DestinationsSection: View {
    let updateCheck: Bool
    let isPreview: Bool
    
    var body: some View {
        Section("Destinations") {
            NavigationLink(destination: {
                if isPreview {
                    EmptyView()
                } else {
                    StarredView()
                }
            }, label: {
                Label("Starred", systemImage: "star")
            })
            // TODO system image availability
            NavigationLink(destination: {
                if isPreview {
                    EmptyView()
                } else {
                    RecentView()
                }
            }, label: {
                Label("Recent", systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90")
            })
            if updateCheck {
                NavigationLink(destination: {
                    if isPreview {
                        EmptyView()
                    } else {
                        UpdateView()
                    }
                }, label: {
                    HStack {
                        Label("Update", systemImage: "arrow.trianglehead.2.clockwise.rotate.90")
                        Spacer()
                        Image(systemName: "smallcircle.filled.circle.fill")
                            .foregroundStyle(.badge)
                    }
                })
            }
        }
        .labelStyle(.titleAndIcon)
        .listRowBackground(ListBackground())
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

//
//  SearchView.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 03-05-2025.
//

import SwiftUI


struct SearchView: View {

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                MainView(isPreview: false)
            }
        } else {
            NavigationView {
                MainView(isPreview: false)
            }
        }
    }
}


private struct MainView: View {
    let isPreview: Bool
    
    @State private var state: SearchState = SearchState()
    
    private let timer = Timer.publish(every: 3600, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            BackgroundView()
            if state.resultList == nil {
                ProgressView()
            } else {
                if #available(iOS 16.0, *) {
                    List {
                        MainView.listContent(query: state.query, resultList: state.resultList!, updateCheck: state.updateCheck ?? false)
                    }
                    .scrollContentBackground(.hidden)
                    .searchable(text: $state.bindQuery(), prompt: "Search")
                } else {
                    List {
                        MainView.listContent(query: state.query, resultList: state.resultList!, updateCheck: state.updateCheck ?? false)
                    }
                    .listStyle(.plain)
                    .searchable(text: $state.bindQuery(), prompt: "Search")
                }
            }
        }
        .navigationTitle("AppName")
        .toolbar {
            HomeToolbarContent()
        }
        .onReceive(timer) { _ in
            Task {
                let db = TheDatabase()
                if state.updateCheck ?? SearchState.cachedUpdateCheck(db: db) {
                    return
                }
                if await SearchState.serverUpdateCheck(db: db) {
                    Config.setUpdateCheck(db: db, value: true)
                    state = state.copyWithUpdateCheck(updateCheck: true)
                }
            }
        }
        .onAppear {
            guard !isPreview else {
                state = state.copyWithResultList(resultList: Demo.resultList).copyWithUpdateCheck(updateCheck: true)
                return
            }
            Task {
                let db = TheDatabase()
                state = await state
                    .copyWithResultList(resultList: SearchState.getResultList(db: db, query: state.query))
                    .copyWithUpdateCheck(updateCheck: SearchState.cachedUpdateCheck(db: db))
            }
        }
    }

    @ViewBuilder
    private static func listContent(query: String, resultList: [SongTitle], updateCheck: Bool) -> some View {
        if query.isEmpty {
            Section("Destinations") {
                NavigationLink(destination: {
                    StarredView()
                }, label: {
                    Label("Starred", systemImage: "star")
                })
                NavigationLink(destination: {
                    RecentView()
                }, label: {
                    Label("Recent", systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                })
                if updateCheck {
                    NavigationLink(destination: {
                        UpdateView()
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
        Section("Results") {
            ForEach(resultList) { result in
                ResultRow(result: result)
            }
        }
    }
}


#Preview {
    if #available(iOS 16.0, *) {
        NavigationStack {
            MainView(isPreview: true)
        }
    } else {
        NavigationView {
            MainView(isPreview: true)
        }
    }
}

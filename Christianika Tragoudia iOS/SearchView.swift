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
    
    var body: some View {
        ZStack {
            BackgroundView()
            if state.resultList == nil {
                ProgressView()
            } else {
                if #available(iOS 16.0, *) {
                    List {
                        MainView.listContent(query: state.query, resultList: state.resultList!)
                    }
                    .scrollContentBackground(.hidden)
                    .searchable(text: $state.bindQuery(), prompt: "Search")
                } else {
                    List {
                        MainView.listContent(query: state.query, resultList: state.resultList!)
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
        .onAppear {
            guard !isPreview else {
                state = state.copyWithResultList(resultList: Demo.resultList)
                return
            }
            Task {
                state = await state.copyWithResultList(resultList: state.search())
            }
        }
    }

    @ViewBuilder
    private static func listContent(query: String, resultList: [SongTitle]) -> some View {
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

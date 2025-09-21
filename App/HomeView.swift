//
//  HomeView.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 03-05-2025.
//

import SwiftUI


private struct ViewState {
    let resultList: [SongTitle]
    let updateCheck: Bool
    
    init(resultList: [SongTitle], updateCheck: Bool) {
        self.resultList = resultList
        self.updateCheck = updateCheck
    }
    
    init(db: TheDatabase) {
        self.resultList = SongTitle.getAll(db: db)
        self.updateCheck = ViewState.cachedUpdateCheck(db: db)
    }
    
    private static func cachedUpdateCheck(db: TheDatabase) -> Bool {
        Config.getUpdateCheck(db: db) ?? false
    }
    
    static func serverUpdateCheck(db: TheDatabase) async -> Bool {
        let oldTimestamp = Config.getUpdateTimestamp(db: db)!
        guard let newTimestamp = await WebApp.getUpdateTimestamp() else { return false }
        return oldTimestamp < newTimestamp
    }
    
    func copyWithUpdateCheck(updateCheck: Bool) -> ViewState {
        ViewState(resultList: self.resultList, updateCheck: updateCheck)
    }
}


struct HomeView: View {
    
    @State private var viewState: ViewState?
    private let isPreview: Bool
    
    @ScaledMetric private var spacing: Double = smallMargin
    
    init(isPreview: Bool) {
        self.viewState = nil
        self.isPreview = isPreview
    }
    
    fileprivate init(viewState: ViewState?) {
        self.viewState = viewState
        self.isPreview = true
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            if let state = viewState {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: spacing) {
                        DestinationsSection(
                            updateCheck: state.updateCheck,
                            isPreview: isPreview,
                        )
                        Text("Index")
                            .modifier(ThemeTitleModifier())
                        ForEach(state.resultList) { result in
                            ThemeResultButton(result: result, isPreview: isPreview)
                        }
                    }
                    .padding(outerPadding)
                    .task {
                        if isPreview { return }
                        let db = TheDatabase()
                        let state = ViewState(db: db)
                        if state.updateCheck {
                            viewState = state
                        } else if await ViewState.serverUpdateCheck(db: db) {
                            Config.setUpdateCheck(db: db, value: true)
                            viewState = state.copyWithUpdateCheck(updateCheck: true)
                        } else {
                            viewState = state
                        }
                    }
                }
            } else {
                ProgressView()
                    .task {
                        if isPreview { return }
                        viewState = ViewState(db: TheDatabase())
                    }
            }
        }
        .navigationTitle("AppName")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                NavigationLink(destination: {
                    SearchView(isPreview: isPreview)
                }, label: {
                    Label("Search", systemImage: "magnifyingglass")
                })
                NavigationLink(destination: {
                    OptionsView(isPreview: isPreview)
                }, label: {
                    Label("Options", systemImage: "gearshape")
                })
            }
        }
        .analyticsScreen(name: String(localized: "Index"), class: "/index/")
    }
}


private struct DestinationsSection: View {
    let updateCheck: Bool
    let isPreview: Bool
    
    var body: some View {
        Text("Destinations")
            .modifier(ThemeTitleModifier())
        NavigationLink(destination: {
            StarredView(isPreview: isPreview)
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
            RecentView(isPreview: isPreview)
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
                UpdateView(isPreview: isPreview)
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
        HomeView(viewState: ViewState(resultList: Demo.resultList, updateCheck: true))
    }
}

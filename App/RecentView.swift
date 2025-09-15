//
//  RecentView.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 24-05-2025.
//

import SwiftUI


// TODO empty content

struct RecentView: View {
    @State private var resultList: [SongTitle]?
    private let isPreview: Bool

    init() {
        self.resultList = nil
        self.isPreview = false
    }
    
    fileprivate init(resultList: [SongTitle]?) {
        self.resultList = resultList
        self.isPreview = true
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            if let resultList {
                List(resultList) { result in
                    ResultRow(result: result, isPreview: isPreview)
                }
                .scrollContentBackground(.hidden)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Recent")
        .toolbar {
            HomeToolbarContent(isPreview: isPreview)
        }
        .task {
            if isPreview { return }
            resultList = SongTitle.getRecent(db: TheDatabase())
        }
        .analyticsScreen(name: String(localized: "Recent"), class: "/recent/")
    }
}


#Preview {
    NavigationStack {
        RecentView(resultList: Demo.resultList)
    }
}

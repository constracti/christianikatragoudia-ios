//
//  StarredView.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 24-05-2025.
//

import SwiftUI


struct StarredView: View {
    @State private var resultList: [SongTitle]?
    private let isPreview: Bool
    
    @ScaledMetric private var spacing: Double = smallMargin
    
    static let systemImage: String = "star"
    
    init(isPreview: Bool) {
        self.resultList = nil
        self.isPreview = isPreview
    }
    
    fileprivate init(resultList: [SongTitle]?) {
        self.resultList = resultList
        self.isPreview = true
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            if let resultList {
                if resultList.isEmpty {
                    ThemeMessage("StarredEmpty", systemImage: StarredView.systemImage)
                        .padding(outerPadding)
                } else {
                    ScrollView {
                        LazyVStack(spacing: spacing) {
                            ForEach(resultList) { result in
                                ThemeResultButton(result: result, isPreview: isPreview)
                            }
                        }
                        .padding(outerPadding)
                    }
                }
            } else {
                ProgressView()
                    .task {
                        if isPreview { return }
                        resultList = SongTitle.getStarred(db: TheDatabase())
                    }
            }
        }
        .navigationTitle("Starred")
        .analyticsScreen(name: String(localized: "Starred"), class: "/starred/")
    }
}


#Preview("Ready") {
    NavigationStack {
        StarredView(resultList: Demo.resultList)
    }
}

#Preview("Empty") {
    NavigationStack {
        StarredView(resultList: [])
    }
}

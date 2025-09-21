//
//  RecentView.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 24-05-2025.
//

import SwiftUI


struct RecentView: View {
    @State private var resultList: [SongTitle]?
    private let isPreview: Bool
    
    @ScaledMetric private var spacing: Double = smallMargin
    
    static var systemImage: String {
        if #available(iOS 18, *) {
            "clock.arrow.trianglehead.counterclockwise.rotate.90"
        } else {
            "clock.arrow.circlepath"
        }
    }

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
                    ThemeMessage("RecentEmpty", systemImage: RecentView.systemImage)
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
                        resultList = SongTitle.getRecent(db: TheDatabase())
                    }
            }
        }
        .navigationTitle("Recent")
        .analyticsScreen(name: String(localized: "Recent"), class: "/recent/")
    }
}


#Preview("Ready") {
    NavigationStack {
        RecentView(resultList: Demo.resultList)
    }
}

#Preview("Empty") {
    NavigationStack {
        RecentView(resultList: [])
    }
}

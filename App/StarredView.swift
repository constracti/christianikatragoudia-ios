//
//  StarredView.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 24-05-2025.
//

import SwiftUI


struct StarredView: View {
    var isPreview: Bool = false
    
    @State private var resultList: [SongTitle]? = nil
    
    var body: some View {
        ZStack {
            BackgroundView()
            if let resultList {
                if #available(iOS 16.0, *) {
                    List(resultList) { result in
                        ResultRow(result: result)
                    }
                    .scrollContentBackground(.hidden)
                } else {
                    List(resultList) { result in
                        ResultRow(result: result)
                    }
                    .listStyle(.plain)
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Starred")
        .toolbar {
            HomeToolbarContent()
        }
        .onAppear {
            guard !isPreview else {
                resultList = Demo.resultList
                return
            }
            Task {
                resultList = SongTitle.getStarred(db: TheDatabase())
            }
        }
        .analyticsScreen(name: String(localized: "Starred"), class: "/starred/")
    }
}


#Preview {
    if #available(iOS 16.0, *) {
        NavigationStack {
            StarredView(isPreview: true)
        }
    } else {
        NavigationView {
            StarredView(isPreview: true)
        }
    }
}

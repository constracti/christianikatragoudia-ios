//
//  RecentView.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 24-05-2025.
//

import SwiftUI


struct RecentView: View {
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
        .navigationTitle("Recent")
        .toolbar {
            HomeToolbarContent()
        }
        .onAppear {
            guard !isPreview else {
                resultList = demoResultList
                return
            }
            Task {
                resultList = SongTitle.getRecent(db: TheDatabase())
            }
        }
    }
}


#Preview {
    if #available(iOS 16.0, *) {
        NavigationStack {
            RecentView(isPreview: true)
        }
    } else {
        NavigationView {
            RecentView(isPreview: true)
        }
    }
}

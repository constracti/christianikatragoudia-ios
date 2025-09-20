//
//  MainToolbarContent.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 20-09-2025.
//

import SwiftUI


struct MainToolbarContent: ToolbarContent {
    let isPreview: Bool
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            NavigationLink(destination: {
                if isPreview {
                    EmptyView()
                } else {
                    OptionsView()
                }
            }, label: {
                Label("Options", systemImage: "gearshape")
            })
        }
    }
}


#Preview {
    NavigationStack {
        ZStack {
            BackgroundView()
        }
        .navigationTitle("AppName")
        .toolbar {
            MainToolbarContent(isPreview: true)
        }
    }
}

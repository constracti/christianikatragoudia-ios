//
//  Common.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 24-05-2025.
//

import SwiftUI


struct HomeToolbarContent: ToolbarContent {
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


struct ResultRow: View {
    let result: SongTitle
    let isPreview: Bool
    
    var body: some View {
        NavigationLink {
            if isPreview {
                EmptyView()
            } else {
                SongView(id: result.id)
            }
        } label: {
            VStack(alignment: .leading) {
                Text(result.title)
                    .font(.headline)
                if (result.title != result.excerpt) {
                    Text(result.excerpt)
                        .font(.subheadline)
                }
            }
        }
        .listRowBackground(ListBackground())
    }
}


// TODO change color on tap

struct ListBackground: View {
    
    var body: some View {
        Color(UIColor.secondarySystemGroupedBackground).opacity(0.5)
    }
}

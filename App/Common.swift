//
//  Common.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 24-05-2025.
//

import SwiftUI


struct HomeToolbarContent: ToolbarContent {
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            NavigationLink(destination: {
                OptionsView()
            }, label: {
                Label("Options", systemImage: "gearshape")
            })
        }
    }
}


struct ResultRow: View {
    let result: SongTitle
    
    var body: some View {
        NavigationLink {
            SongView(id: result.id)
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

//
//  ThemeResultButton.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 17-09-2025.
//

import SwiftUI


struct ThemeResultButton: View {
    let result: SongTitle
    let isPreview: Bool
    
    var body: some View {
        NavigationLink(destination: {
            SongView(id: result.id, isPreview: isPreview)
        }, label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(result.title)
                        .font(.headline)
                    if (result.title != result.excerpt) {
                        Text(result.excerpt)
                            .font(.subheadline)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
            }
        })
        .buttonStyle(ThemeButtonStyle())
    }
}


#Preview {
    NavigationStack {
        ZStack {
            BackgroundView()
            ThemeResultButton(result: Demo.resultList[0], isPreview: true)
            .padding(outerPadding)
        }
        .navigationTitle("AppName")
    }
}

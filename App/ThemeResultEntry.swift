//
//  ThemeResultEntry.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 18-09-2025.
//

import SwiftUI


struct ThemeResultEntry: View {
    let result: SongTitle
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(result.title)
                .font(.headline)
            if (result.title != result.excerpt) {
                Text(result.excerpt)
                    .font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .modifier(ThemeEntryModifier())
    }
}


#Preview {
    NavigationStack {
        ZStack {
            BackgroundView()
            ThemeResultEntry(result: Demo.resultList[0])
                .padding(outerPadding)
        }
    }
}

//
//  ThemeButtonStyle.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 17-09-2025.
//

import SwiftUI


struct ThemeButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .modifier(ThemeEntryModifier(isPressed: configuration.isPressed))
    }
}


#Preview {
    NavigationStack {
        ZStack {
            BackgroundView()
            NavigationLink("AppName", destination: {
                EmptyView()
            })
            .buttonStyle(ThemeButtonStyle())
            .padding(outerPadding)
        }
    }
}

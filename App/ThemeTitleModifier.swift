//
//  ThemeTitleModifier.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 18-09-2025.
//

import SwiftUI


struct ThemeTitleModifier: ViewModifier {
    
    @ScaledMetric private var indent: Double = largeMargin
    
    func body(content: Content) -> some View {
        content
            .textCase(.uppercase)
            .foregroundStyle(.accent)
            .font(.callout)
            .padding(.horizontal, indent)
    }
}


#Preview {
    NavigationStack {
        ZStack {
            BackgroundView()
            Text("AppName")
                .modifier(ThemeTitleModifier())
                .padding(outerPadding)
        }
    }
}

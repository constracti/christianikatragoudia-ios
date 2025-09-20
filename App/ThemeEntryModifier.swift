//
//  ThemeEntryModifier.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 18-09-2025.
//

import SwiftUI


struct ThemeEntryModifier: ViewModifier {
    
    private let background: Color
    private let isSquare: Bool
    
    init() {
        self.background = .backgroundDefault
        self.isSquare = false
    }
    
    init(isPressed: Bool) {
        self.background = isPressed ? .backgroundActive : .backgroundDefault
        self.isSquare = false
    }
    
    init(isSquare: Bool) {
        self.background = .backgroundDefault
        self.isSquare = isSquare
    }
    
    @ScaledMetric private var smallValue: Double = smallMargin
    @ScaledMetric private var largeValue: Double = largeMargin
    
    func body(content: Content) -> some View {
        content
            .padding(EdgeInsets(
                top: smallValue,
                leading: isSquare ? smallValue : largeValue,
                bottom: smallValue,
                trailing: isSquare ? smallValue : largeValue,
            ))
            .background(background)
            .clipShape(RoundedRectangle(cornerSize: .init(
                width: smallValue,
                height: isSquare ? smallValue : largeValue,
            )))
    }
}


#Preview("Default") {
    NavigationStack {
        ZStack {
            BackgroundView()
            Text("AppName")
                .modifier(ThemeEntryModifier())
        }
    }
}


#Preview("Active") {
    NavigationStack {
        ZStack {
            BackgroundView()
            Text("AppName")
                .modifier(ThemeEntryModifier(isPressed: true))
                .padding(outerPadding)
        }
    }
}


#Preview("Square") {
    NavigationStack {
        ZStack {
            BackgroundView()
            Text("AppName")
                .modifier(ThemeEntryModifier(isSquare: true))
                .padding(outerPadding)
        }
    }
}

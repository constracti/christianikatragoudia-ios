//
//  ThemeMessage.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 17-09-2025.
//

import SwiftUI


struct ThemeMessage: View {
    private let titleKey: LocalizedStringKey
    private let systemImage: String
    
    @ScaledMetric private var spacing: Double = largeMargin
    
    init(_ titleKey: LocalizedStringKey, systemImage: String) {
        self.titleKey = titleKey
        self.systemImage = systemImage
    }
    
    var body: some View {
        VStack(spacing: spacing) {
            Image(systemName: systemImage)
            Text(titleKey)
                .multilineTextAlignment(.center)
        }
        .padding(spacing)
        .background(.backgroundDefault)
        .clipShape(RoundedRectangle(cornerRadius: spacing))
    }
}


#Preview {
    NavigationStack {
        ZStack {
            BackgroundView()
            ThemeMessage("DownloadError", systemImage: "multiply.circle")
                .padding(outerPadding)
        }
        .navigationTitle("AppName")
    }
}

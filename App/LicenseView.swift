//
//  LicenseView.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 14-05-2025.
//

import SwiftUI


struct LicenseView: View {
    
    var body: some View {
        ZStack {
            BackgroundView()
            ScrollView {
                VStack(alignment: .leading, spacing: 24.0) {
                    Text("LicenseLong")
                    Image("license")
                    Divider()
                    let markdown = String(localized: "LicenseContent")
                    if let rich = try? AttributedString(
                        markdown: markdown,
                        options: AttributedString.MarkdownParsingOptions(
                            interpretedSyntax: .inlineOnly,
                        ),
                    ) {
                        Text(rich)
                    } else {
                        Text(markdown)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("License")
        .toolbar {
            if let url = URL(string: String(localized: "LicenseUrl")) {
                ToolbarItem(placement: .bottomBar) {
                    Link("Details", destination: url)
                }
            }
        }
        .analyticsScreen(name: String(localized: "License"), class: "/license/")
    }
}


#Preview {
    NavigationStack {
        LicenseView()
    }
}

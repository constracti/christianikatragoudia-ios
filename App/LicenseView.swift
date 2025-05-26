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
                    let markdown = [
                        String(localized: "LicenseIntroduction"),
                        "",
                        "**" + String(localized: "LicenseAttributionTitle") + "**",
                        String(localized: "LicenseAttributionContent"),
                        "",
                        "**" + String(localized: "LicenseNonCommercialTitle") + "**",
                        String(localized: "LicenseNonCommercialContent"),
                        "",
                        "**" + String(localized: "LicenseShareAlikeTitle") + "**",
                        String(localized: "LicenseShareAlikeContent"),
                    ].joined(separator: "\n")
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
            ToolbarItem(placement: .bottomBar) {
                Link("Details", destination: URL(string: String(localized: "LicenseUrl"))!)
            }
        }
        .analyticsScreen(name: String(localized: "License"), class: "/license/")
    }
}


#Preview {
    if #available(iOS 16.0, *) {
        NavigationStack {
            LicenseView()
        }
    } else {
        NavigationView {
            LicenseView()
        }
    }
}

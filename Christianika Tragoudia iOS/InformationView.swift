//
//  InformationView.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 14-05-2025.
//

import SwiftUI


struct InformationView: View {
    
    var body: some View {
        ZStack {
            BackgroundView()
            ScrollView {
                let markdown = [
                    String(localized: "InformationDescription"),
                    "",
                    String(localized: "InformationFeatures"),
                    "",
                    String(localized: "InformationExtras"),
                    "*[\(WebApp.homeHost)](\(WebApp.homeString))*",
                    "",
                    String(localized: "InformationContribution"),
                    "",
                    String(localized: "InformationDeveloper"),
                    "*\(WebApp.mailString)*",
                ].joined(separator: "\n")
                if let rich = try? AttributedString(
                    markdown: markdown,
                    options: AttributedString.MarkdownParsingOptions(
                        interpretedSyntax: .inlineOnly,
                    ),
                ) {
                    Text(rich)
                        .padding()
                } else {
                    Text(markdown)
                        .padding()
                }
            }
        }
        .navigationTitle("Information")
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Link("InformationOpenSite", destination: WebApp.homeUrl)
                Link("InformationSendMail", destination: WebApp.mailUrl)
            }
        }
    }
}


#Preview {
    if #available(iOS 16.0, *) {
        NavigationStack {
            InformationView()
        }
    } else {
        NavigationView {
            InformationView()
        }
    }
}

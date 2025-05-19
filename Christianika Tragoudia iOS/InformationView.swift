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
                    "*[\(Patch.domain)](\(Patch.home))*",
                    "",
                    String(localized: "InformationContribution"),
                    "",
                    String(localized: "InformationDeveloper"),
                    "*\(Patch.email)*",
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
                Link("InformationOpenSite", destination: URL(string: Patch.home)!)
                Link("InformationSendMail", destination: URL(string: "mailto:" + Patch.email)!)
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

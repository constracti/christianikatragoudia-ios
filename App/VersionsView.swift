//
//  VersionView.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 24-05-2025.
//

import SwiftUI


struct VersionsView: View {
    
    var body: some View {
        ZStack {
            BackgroundView()
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(Version.ALL.reversed(), id: \.tag) { version in
                        HStack {
                            Text(String(localized: "Version") + " " + version.tag)
                                .font(.body.bold())
                                .foregroundStyle(.accent)
                            Spacer()
                            Text(version.date)
                                .font(.caption)
                        }
                        Spacer(minLength: 8)
                        let markdown = version.changes.split(separator: /\n/).map({ entry in
                            "- " + entry
                        }).joined(separator: "\n")
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
                        Spacer(minLength: 24)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("VersionHistory")
        .analyticsScreen(name: String(localized: "VersionHistory"), class: "/versions/")
    }
}


#Preview {
    NavigationStack {
        VersionsView()
    }
}

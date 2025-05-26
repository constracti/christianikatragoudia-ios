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
                        Spacer(minLength: 8.0)
                        let x = version.changes.components(separatedBy: "\n")
                        ForEach(x, id: \.self) { change in
                            Text("- " + change)
                            Spacer(minLength: 8.0)
                        }
                        Spacer(minLength: 24.0)
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
    if #available(iOS 16.0, *) {
        NavigationStack {
            VersionsView()
        }
    } else {
        NavigationView {
            VersionsView()
        }
    }
}

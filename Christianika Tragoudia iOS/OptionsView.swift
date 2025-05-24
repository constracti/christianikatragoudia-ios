//
//  OptionsView.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 14-05-2025.
//

import SwiftUI


struct OptionsView: View {
    
    var body: some View {
        ZStack {
            BackgroundView()
            if #available(iOS 16.0, *) {
                List(content: listContent)
                    .scrollContentBackground(.hidden)
            } else {
                List(content: listContent)
                    .listStyle(.plain)
            }
        }
        .navigationTitle("Options")
    }
    
    @ViewBuilder
    private func listContent() -> some View {
        Section("Settings") {
            NavigationLink("Tonalities") {
                TonalitiesView()
            }
        }
        .listRowBackground(ListBackground())
        Section("Tools") {
            NavigationLink("Update") {
                UpdateView()
            }
        }
        .listRowBackground(ListBackground())
        Section("App") {
            NavigationLink("Information") {
                InformationView()
            }
            NavigationLink(destination: {
                LicenseView()
            }, label: {
                VStack(alignment: .leading) {
                    Text("License")
                    Text("LicenseShort")
                        .font(.caption)
                }
            })
            // TODO version view
            HStack {
                Text("Version")
                Spacer()
                Text("1.0")
            }
        }
        .listRowBackground(ListBackground())
    }
}


#Preview {
    if #available(iOS 16.0, *) {
        NavigationStack {
            OptionsView()
        }
    } else {
        NavigationView {
            OptionsView()
        }
    }
}

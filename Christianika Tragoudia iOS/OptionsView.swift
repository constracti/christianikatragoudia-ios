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
                List {
                    ListContent()
                }
                .scrollContentBackground(.hidden)
            } else {
                List {
                    ListContent()
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Options")
    }
}


private struct ListContent: View {
    
    var body: some View {
        // TODO short descriptions under titles
        Section("Settings") {
            NavigationLink("Tonalities") {
                Text("TODO Tonalities View")
            }
        }
        .listRowBackground(itemBackground())
        Section("Tools") {
            NavigationLink("Update") {
                UpdateView()
            }
        }
        .listRowBackground(itemBackground())
        Section("App") {
            NavigationLink("Information") {
                InformationView()
            }
            NavigationLink("License") {
                LicenseView()
            }
            NavigationLink("Version") {
                Text("TODO Version View")
            }
        }
        .listRowBackground(itemBackground())
    }
    
    @ViewBuilder
    private func itemBackground() -> some View {
        // TODO change color on tap
        Color(UIColor.secondarySystemGroupedBackground).opacity(0.5)
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

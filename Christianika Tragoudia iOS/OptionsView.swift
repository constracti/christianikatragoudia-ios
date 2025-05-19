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
        // TODO short descriptions under titles
        // TODO tonalities
//        Section("Settings") {
//            NavigationLink("Tonalities") {
//                Text("Tonalities")
//            }
//        }
//        .listRowBackground(listItemBackground())
        Section("Tools") {
            NavigationLink("Update") {
                UpdateView()
            }
        }
        .listRowBackground(listItemBackground())
        Section("App") {
            NavigationLink("Information") {
                InformationView()
            }
            NavigationLink("License") {
                LicenseView()
            }
            // TODO version
//            NavigationLink("Version") {
//                Text("Version")
//            }
        }
        .listRowBackground(listItemBackground())
    }
    
    private func listItemBackground() -> some View {
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

//
//  OptionsView.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 14-05-2025.
//

import SwiftUI


struct OptionsView: View {
    private let isPreview: Bool
    
    init() {
        self.isPreview = false
    }
    
    fileprivate init(isPreview: Bool) {
        self.isPreview = isPreview
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            List {
                SettingsSection(isPreview: isPreview)
                ToolsSection(isPreview: isPreview)
                AppSection()
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Options")
        .analyticsScreen(name: String(localized: "Options"), class: "/options/")
    }
}


private struct SettingsSection: View {
    let isPreview: Bool
    
    var body: some View {
        Section("Settings") {
            NavigationLink(destination: {
                if isPreview {
                    EmptyView()
                } else {
                    TonalitiesView()
                }
            }, label: {
                VStack(alignment: .leading) {
                    Text("Tonalities")
                    Text("TonalitiesDescription")
                        .font(.caption)
                }
            })
        }
        .listRowBackground(ListBackground())
    }
}


private struct ToolsSection: View {
    let isPreview: Bool
    @State private var clearRecentVisible: Bool = false
    @State private var resetTonalityVisible: Bool = false
    @State private var resetZoomVisible: Bool = false
    
    var body: some View {
        Section("Tools") {
            NavigationLink(destination: {
                if isPreview {
                    EmptyView()
                } else {
                    UpdateView()
                }
            }, label: {
                VStack(alignment: .leading) {
                    Text("Update")
                    Text("UpdateDescription")
                        .font(.caption)
                }
            })
            Button("ClearRecent", action: {
                clearRecentVisible = true
            })
            Button("ResetTonality", action: {
                resetTonalityVisible = true
            })
            Button("ResetZoom", action: {
                resetZoomVisible = true
            })
        }
        .listRowBackground(ListBackground())
        .buttonStyle(.plain)
        .alert("ClearRecent", isPresented: $clearRecentVisible, actions: {
            Button("Cancel", role: .cancel, action: {})
            Button("Clear", role: .destructive, action: {
                if isPreview { return }
                let db = TheDatabase()
                SongMeta.clearVisited(db: db)
            })
            .keyboardShortcut(.defaultAction)
        }, message: {
            Text("ClearRecentMessage")
        })
        .alert("ResetTonality", isPresented: $resetTonalityVisible, actions: {
            Button("Cancel", role: .cancel, action: {})
            Button("Reset", role: .destructive, action: {
                if isPreview { return }
                let db = TheDatabase()
                ChordMeta.resetTonality(db: db)
            })
            .keyboardShortcut(.defaultAction)
        }, message: {
            Text("ResetTonalityMessage")
        })
        .alert("ResetZoom", isPresented: $resetZoomVisible, actions: {
            Button("Cancel", role: .cancel, action: {})
            Button("Reset", role: .destructive, action: {
                if isPreview { return }
                let db = TheDatabase()
                SongMeta.resetZoom(db: db)
                ChordMeta.resetZoom(db: db)
            })
            .keyboardShortcut(.defaultAction)
        }, message: {
            Text("ResetZoomMessage")
        })
    }
}


private struct AppSection: View {

    var body: some View {
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
            NavigationLink(destination: {
                VersionsView()
            }, label: {
                VStack(alignment: .leading) {
                    Text("Version")
                    Text(Version.CURRENT)
                        .font(.caption)
                }
            })
        }
        .listRowBackground(ListBackground())
    }
}


#Preview {
    NavigationStack {
        OptionsView(isPreview: true)
    }
}

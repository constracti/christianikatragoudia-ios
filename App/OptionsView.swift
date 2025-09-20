//
//  OptionsView.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 14-05-2025.
//

import SwiftUI


struct OptionsView: View {
    private let isPreview: Bool
    
    @ScaledMetric private var spacing: Double = smallMargin
    
    init() {
        self.isPreview = false
    }
    
    fileprivate init(isPreview: Bool) {
        self.isPreview = isPreview
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            ScrollView {
                LazyVStack(alignment: .leading, spacing: spacing) {
                    SettingsSection(isPreview: isPreview)
                    ToolsSection(isPreview: isPreview)
                    AppSection()
                }
                .padding(outerPadding)
            }
        }
        .navigationTitle("Options")
        .analyticsScreen(name: String(localized: "Options"), class: "/options/")
    }
}


private struct SettingsSection: View {
    let isPreview: Bool
    
    var body: some View {
        Text("Settings")
            .modifier(ThemeTitleModifier())
        NavigationLink(destination: {
            if isPreview {
                EmptyView()
            } else {
                TonalitiesView()
            }
        }, label: {
            HStack {
                VStack(alignment: .leading) {
                    Text("Tonalities")
                    Text("TonalitiesDescription")
                        .font(.caption)
                }
                Spacer()
                Image(systemName: "chevron.right")
            }
        })
        .buttonStyle(ThemeButtonStyle())
    }
}


private struct ToolsSection: View {
    let isPreview: Bool
    
    @State private var clearRecentVisible: Bool = false
    @State private var resetTonalityVisible: Bool = false
    @State private var resetZoomVisible: Bool = false
    
    var body: some View {
        Text("Tools")
            .modifier(ThemeTitleModifier())
        NavigationLink(destination: {
            if isPreview {
                EmptyView()
            } else {
                UpdateView()
            }
        }, label: {
            HStack {
                VStack(alignment: .leading) {
                    Text("Update")
                    Text("UpdateDescription")
                        .font(.caption)
                }
                Spacer()
                Image(systemName: "chevron.right")
            }
        })
        .buttonStyle(ThemeButtonStyle())
        Button(action: {
            clearRecentVisible = true
        }, label: {
            Text("ClearRecent")
                .frame(maxWidth: .infinity, alignment: .leading)
        })
        .buttonStyle(ThemeButtonStyle())
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
        Button(action: {
            resetTonalityVisible = true
        }, label: {
            Text("ResetTonality")
                .frame(maxWidth: .infinity, alignment: .leading)
        })
        .buttonStyle(ThemeButtonStyle())
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
        Button(action: {
            resetZoomVisible = true
        }, label: {
            Text("ResetZoom")
                .frame(maxWidth: .infinity, alignment: .leading)
        })
        .buttonStyle(ThemeButtonStyle())
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
        Text("App")
            .modifier(ThemeTitleModifier())
        NavigationLink(destination: {
            InformationView()
        }, label: {
            HStack {
                Text("Information")
                Spacer()
                Image(systemName: "chevron.right")
            }
        })
        .buttonStyle(ThemeButtonStyle())
        NavigationLink(destination: {
            LicenseView()
        }, label: {
            HStack {
                VStack(alignment: .leading) {
                    Text("License")
                    Text("LicenseShort")
                        .font(.caption)
                }
                Spacer()
                Image(systemName: "chevron.right")
            }
        })
        .buttonStyle(ThemeButtonStyle())
        NavigationLink(destination: {
            VersionsView()
        }, label: {
            HStack {
                VStack(alignment: .leading) {
                    Text("Version")
                    Text(Version.CURRENT)
                        .font(.caption)
                }
                Spacer()
                Image(systemName: "chevron.right")
            }
        })
        .buttonStyle(ThemeButtonStyle())
    }
}


#Preview {
    NavigationStack {
        OptionsView(isPreview: true)
    }
}

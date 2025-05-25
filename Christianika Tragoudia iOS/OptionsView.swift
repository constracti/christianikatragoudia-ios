//
//  OptionsView.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 14-05-2025.
//

import SwiftUI


struct OptionsView: View {
    
    @State private var clearRecentVisible: Bool = false
    @State private var resetTonalityVisible: Bool = false
    @State private var resetZoomVisible: Bool = false
    
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
        .alert("ClearRecent", isPresented: $clearRecentVisible, actions: {
            Button("Cancel", role: .cancel, action: {})
            Button("Clear", role: .destructive, action: {
                SongMeta.clearVisited(db: TheDatabase())
            })
            .keyboardShortcut(.defaultAction)
        }, message: {
            Text("ClearRecentMessage")
        })
        .alert("ResetTonality", isPresented: $resetTonalityVisible, actions: {
            Button("Cancel", role: .cancel, action: {})
            Button("Reset", role: .destructive, action: {
                ChordMeta.resetTonality(db: TheDatabase())
            })
            .keyboardShortcut(.defaultAction)
        }, message: {
            Text("ResetTonalityMessage")
        })
        .alert("ResetZoom", isPresented: $resetZoomVisible, actions: {
            Button("Cancel", role: .cancel, action: {})
            Button("Reset", role: .destructive, action: {
                let db = TheDatabase()
                SongMeta.resetZoom(db: db)
                ChordMeta.resetZoom(db: db)
            })
            .keyboardShortcut(.defaultAction)
        }, message: {
            Text("ResetZoomMessage")
        })
    }
    
    @ViewBuilder
    private func listContent() -> some View {
        Section("Settings") {
            NavigationLink(destination: {
                TonalitiesView()
            }, label: {
                VStack(alignment: .leading) {
                    Text("Tonalities")
                    Text("TonalitiesDescription")
                        .font(.caption)
                }
            })
        }
        .listRowBackground(ListBackground())
        Section("Tools") {
            NavigationLink(destination: {
                UpdateView()
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
                VersionView()
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

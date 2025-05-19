//
//  WelcomeView.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 22-04-2025.
//

import SwiftUI


enum WelcomeState {
    case starting
    case loading
    case prompting
}


struct WelcomeView: View {
    @Binding var passed: Bool
    
    @State var state: WelcomeState = .starting

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                WelcomeMain(passed: $passed, state: $state)
            }
        } else {
            NavigationView {
                WelcomeMain(passed: $passed, state: $state)
            }
        }
    }
}


private struct WelcomeMain: View {
    @Binding var passed: Bool
    @Binding var state: WelcomeState
    
    @State var errorVisible: Bool = false
    
    var body: some View {
        ZStack {
            BackgroundView()
            switch state {
            case .starting:
                ProgressView()
                    .task {
                        let db = TheDatabase()
                        passed = Song.count(db: db) > 0
                        state = .prompting
                    }
            case .loading:
                ProgressView()
            case .prompting:
                VStack {
                    Text("DownloadPrompt")
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Download", systemImage: "square.and.arrow.down", action: {
                        Task {
                            state = .loading
                            await download()
                            state = .prompting
                        }
                    })
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        NavigationLink("Information") {
                            InformationView()
                        }
                        NavigationLink("License") {
                            LicenseView()
                        }
                    }
                }
            }
        }
        .navigationTitle("AppName")
        .alert("Error", isPresented: $errorVisible, actions: {}, message: {
            Text("DownloadError")
        })
    }
    
    private func download() async -> Void {
        let patch = await Patch.get(after: nil, full: true)
        if (patch != nil) {
            let db = TheDatabase()
            Song.insert(db: db, songList: patch!.songList)
            SongFts.insert(db: db, ftsList: patch!.songList.map { song in
                SongFts(song: song)
            })
            SongFts.optimize(db: db)
            Chord.insert(db: db, chordList: patch!.chordList)
            Config.setUpdateTimestamp(db: db, value: patch!.timestamp)
            passed = Song.count(db: db) > 0
        } else {
            errorVisible = true
        }
    }
}


#Preview {
    WelcomeView(passed: .constant(false), state: .prompting)
}

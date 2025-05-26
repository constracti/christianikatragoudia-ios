//
//  WelcomeView.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 22-04-2025.
//

import SwiftUI


private enum ViewState {
    case START
    case READY
    case DOWNLOAD
}


struct WelcomeView: View {
    @Binding var passed: Bool

    @State private var state: ViewState = .START
    
    var body: some View {
        MainView(passed: $passed, state: $state)
    }
}


private struct MainView: View {
    @Binding var passed: Bool
    @Binding var state: ViewState
    
    @State private var errorVisible: Bool = false
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack(root: navigationContent)
        } else {
            NavigationView(content: navigationContent)
        }
    }
    
    private func navigationContent() -> some View {
        ZStack {
            BackgroundView()
            switch state {
            case .START:
                ProgressView()
                    .task {
                        let db = TheDatabase()
                        passed = Song.count(db: db) > 0
                        state = .READY
                    }
            case .READY:
                VStack {
                    Text("DownloadPrompt")
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Download", systemImage: "square.and.arrow.down") {
                        state = .DOWNLOAD
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
            case .DOWNLOAD:
                ProgressView()
                    .task(downloadTask)
            }
        }
        .navigationTitle("AppName")
        .alert("Error", isPresented: $errorVisible, actions: {}, message: {
            Text("DownloadError")
        })
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                NavigationLink("Information", destination: {
                    InformationView()
                })
                .disabled(state != .READY)
                NavigationLink("License", destination: {
                    LicenseView()
                })
                .disabled(state != .READY)
            }
        }
    }
    
    @Sendable
    private func downloadTask() async -> Void {
        state = .DOWNLOAD
        if let patch = await Patch.get(after: nil, full: true) {
            let db = TheDatabase()
            Song.insert(db: db, songList: patch.songList)
            SongFts.insert(db: db, ftsList: patch.songList.map({ SongFts(song: $0) }))
            SongFts.optimize(db: db)
            Chord.insert(db: db, chordList: patch.chordList)
            Config.setUpdateTimestamp(db: db, value: patch.timestamp)
            Config.setUpdateCheck(db: db, value: false)
            passed = Song.count(db: db) > 0
        } else {
            errorVisible = true
        }
        state = .READY
    }
}


#Preview {
    MainView(passed: .constant(false), state: .constant(.READY))
}

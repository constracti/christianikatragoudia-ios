//
//  WelcomeView.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 22-04-2025.
//

import SwiftUI


private enum ViewState {
    case start
    case ready
    case download
}


struct WelcomeView: View {
    @Binding var passed: Bool
    @State private var state: ViewState
    private let isPreview: Bool
    
    @State private var errorVisible: Bool = false
    
    init(passed: Binding<Bool>) {
        self._passed = passed
        self.state = .start
        self.isPreview = false
    }
    
    fileprivate init(passed: Binding<Bool>, state: ViewState) {
        self._passed = passed
        self.state = state
        self.isPreview = true
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            switch state {
            case .start:
                ProgressView()
                    .task {
                        if isPreview { return }
                        let db = TheDatabase()
                        passed = Song.count(db: db) > 0
                        state = .ready
                    }
            case .ready:
                VStack {
                    Text("DownloadPrompt")
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Download", systemImage: "square.and.arrow.down", action: {
                        state = .download
                    })
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
                .analyticsScreen(name: String(localized: "Welcome"), class: "/welcome/")
            case .download:
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
                .disabled(state != .ready)
                NavigationLink("License", destination: {
                    LicenseView()
                })
                .disabled(state != .ready)
            }
        }
    }
    
    @Sendable
    private func downloadTask() async -> Void {
        if isPreview { return }
        if let patch = await Patch.get(after: nil, full: true) {
            let db = TheDatabase()
            db.beginTransaction()
            Song.insert(db: db, songList: patch.songList)
            SongFts.insert(db: db, ftsList: patch.songList.map({ SongFts(song: $0) }))
            SongFts.optimize(db: db)
            Chord.insert(db: db, chordList: patch.chordList)
            Config.setUpdateTimestamp(db: db, value: patch.timestamp)
            Config.setUpdateCheck(db: db, value: false)
            db.commitTransaction()
            passed = Song.count(db: db) > 0
        } else {
            errorVisible = true
        }
        state = .ready
        TheAnalytics.logUpdateApply()
    }
}


#Preview("Start") {
    NavigationStack {
        WelcomeView(passed: .constant(false), state: .start)
    }
}


#Preview("Ready") {
    NavigationStack {
        WelcomeView(passed: .constant(false), state: .ready)
    }
}


#Preview("Download") {
    NavigationStack {
        WelcomeView(passed: .constant(false), state: .download)
    }
}

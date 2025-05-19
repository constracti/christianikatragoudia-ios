//
//  UpdateView.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 18-05-2025.
//

import SwiftUI


struct UpdateView: View {
    
    @State var loading: Bool = true
    @State var errorVisible: Bool = false
    
    var body: some View {
        ZStack {
            BackgroundView()
            switch loading {
            case true:
                ProgressView()
                    .task {
                        let after = Config.getUpdateTimestamp(db: TheDatabase())
                        let patch = await Patch.get(after: after, full: false)
                        if patch != nil {
                            print("patch", patch!.timestamp)
                        } else {
                            errorVisible = true
                        }
                        loading = false
                    }
            case false:
                Text("loaded")
            }
        }
        .navigationTitle("Update")
        .alert("Error", isPresented: $errorVisible, actions: {}, message: {
            Text("DownloadError")
        })
    }
}


#Preview {
    if #available(iOS 16.0, *) {
        NavigationStack {
            UpdateView()
        }
    } else {
        NavigationView {
            UpdateView()
        }
    }
}

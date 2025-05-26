//
//  TonalitiesView.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 20-05-2025.
//

import SwiftUI


struct TonalitiesView: View {
    
    @State private var hiddenTonalities: Set<MusicNote>? = nil
    
    var body: some View {
        ZStack {
            BackgroundView()
            if hiddenTonalities == nil {
                ProgressView()
                    .task {
                        hiddenTonalities = Config.getHiddenTonalities(db: TheDatabase()) ?? MusicNote.ENHARMONIC_TONALITIES
                    }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("TonalitiesDescription")
                            .padding(8)
                        let tonalitiesByStep: [[MusicNote]] = MusicNote.TONALITIES.reduce(into: ([[MusicNote]](), [MusicNote]()), { acc, tonality in
                            acc.1.append(tonality)
                            if acc.1.count == 3 {
                                acc.0.append(acc.1)
                                acc.1 = [MusicNote]()
                            }
                        }).0
                        ForEach(Array(tonalitiesByStep.enumerated()), id: \.offset) { _, row in
                            HStack(spacing: 0) {
                                ForEach(row) { tonality in
                                    Toggle(tonality.notation, isOn: Binding(
                                        get: {
                                            !hiddenTonalities!.contains(tonality)
                                        },
                                        set: { isOn in
                                            if isOn {
                                                hiddenTonalities!.remove(tonality)
                                            } else {
                                                hiddenTonalities!.insert(tonality)
                                            }
                                            Config.setHiddenTonalities(db: TheDatabase(), value: hiddenTonalities)
                                        },
                                    ))
                                    .tint(.accent)
                                    .padding(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(UIColor.systemFill)),
                                    )
                                    .padding(8)
                                }
                            }
                        }
                    }
                    .padding(8)
                }
            }
        }
        .navigationTitle("Tonalities")
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("Reset") {
                    hiddenTonalities = MusicNote.ENHARMONIC_TONALITIES
                    Config.setHiddenTonalities(db: TheDatabase(), value: nil)
                }
            }
        }
        .analyticsScreen(name: String(localized: "Tonalities"), class: "/options/tonalities/")
    }
}

#Preview {
    if #available(iOS 16.0, *) {
        NavigationStack {
            TonalitiesView()
        }
    } else {
        NavigationView {
            TonalitiesView()
        }
    }
}

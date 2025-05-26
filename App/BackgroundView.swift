//
//  BackgroundView.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 03-05-2025.
//

import SwiftUI


struct BackgroundView: View {

    var body: some View {
        Image("piano-treble-clef")
            .resizable()
            .aspectRatio(contentMode: .fill)
            // https://stackoverflow.com/a/59111069
            .frame(minWidth: 0, minHeight: 0, alignment: .topTrailing)
            .ignoresSafeArea()
    }
}


#Preview {
    BackgroundView()
}

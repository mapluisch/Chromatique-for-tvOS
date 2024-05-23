//
//  MediaInfoView.swift
//  Chromatique
//
//  Created by Martin Pluisch on 23.05.24.
//

import SwiftUI
import MediaPlayer

struct MediaInfoView: View {
    let nowPlayingItem: MPMediaItem?

    var body: some View {
        HStack(spacing: 4) {
            if let item = nowPlayingItem {
                if let artwork = item.artwork, let image = artwork.image(at: CGSize(width: 125, height: 125)) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 125, height: 125)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                } else {
                    Image(systemName: "music.note")
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 125, height: 125)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }

                VStack(alignment: .leading) {
                    Text(item.title ?? "Unknown Title")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(item.albumTitle ?? "Unknown Album")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    Text(item.artist ?? "Unknown Artist")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .padding(.leading)
            } else {
                Text("No media playing")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
    }
}

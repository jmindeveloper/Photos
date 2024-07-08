//
//  AlbumCoverView.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/9/24.
//

import SwiftUI

struct AlbumCoverView: View {
    @State var album: Album
    @State var uiImage: UIImage? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            GeometryReader { proxy in
                if let image = uiImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .foregroundColor(.clear)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFill()
                        .foregroundColor(.gray)
                        .frame(width: 60, height: 60)
                        .clipped()
                        .position(x: proxy.frame(in: .local).midX, y: proxy.frame(in: .local).midY)
                }
            }
            
            Text(album.title)
                .foregroundColor(Color(uiColor: .label))
            
            Text("\(album.assetCount)")
                .foregroundColor(.gray)
        }
        .onAppear {
            PhotoLibrary.requestImage(with: album.assets.last) { image, _ in
                uiImage = image
            }
        }
    }
}

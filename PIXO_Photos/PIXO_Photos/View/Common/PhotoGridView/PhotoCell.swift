//
//  PhotoCell.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/7/24.
//

import SwiftUI
import Photos

struct PhotoCell: View {
    @State var uiImage: UIImage? = nil
    @State var duration: Int? = nil
    private var asset: PHAsset? = nil
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            GeometryReader { proxy in
                if let image = uiImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFill()
                        .foregroundColor(.gray)
                        .frame(width: 30, height: 30)
                        .clipped()
                        .position(x: proxy.frame(in: .local).midX, y: proxy.frame(in: .local).midY)
                }
            }
            .onAppear {
                PhotoLibrary.requestImage(with: asset) { image, duration in
                    uiImage = image
                    self.duration = duration
                }
            }
            
            if let duration = duration {
                // TODO: - seconds to min:sec 로 변경
                Text("\(duration)")
                    .foregroundColor(.white)
                    .font(.system(size: 14))
                    .padding([.bottom, .trailing], 2)
            }
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    PhotoCell()
        .frame(width: 100, height: 100)
}


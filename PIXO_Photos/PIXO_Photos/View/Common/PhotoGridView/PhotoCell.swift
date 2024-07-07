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
    private var contentMode = ContentMode.fill
    private var isSelected: Bool = false
    
    init(asset: PHAsset) {
        self.asset = asset
    }
    
    private init(asset: PHAsset?, contentMode: ContentMode, isSelected: Bool) {
        self.asset = asset
        self.contentMode = contentMode
        self.isSelected = isSelected
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            GeometryReader { proxy in
                if let image = uiImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .contentShape(Rectangle())
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
            
            if isSelected {
                Color.black.opacity(0.3)
                
                Image(systemName: "checkmark.circle")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(Color.blue))
                    .padding([.bottom, .trailing], 2)
            }
        }
    }
    
    func contentMode(_ mode: ContentMode) -> PhotoCell {
        PhotoCell(asset: asset, contentMode: mode, isSelected: isSelected)
    }
    
    func isSelected(_ isSelected: Bool) -> PhotoCell {
        PhotoCell(asset: asset, contentMode: contentMode, isSelected: isSelected)
    }
}

//
//  PhotoGridView.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/7/24.
//

import SwiftUI
import Photos

struct PhotoGridView: View {
    @State var columnItemCount: Int = 3
    @Binding var assets: [PHAsset]
    private let spacingWidth: CGFloat = 1
    
    init(assets: Binding<[PHAsset]>) {
        self._assets = assets
    }
    
    var body: some View {
        let gridItem = Array(
            repeating: GridItem(.flexible(), spacing: spacingWidth),
            count: columnItemCount
        )
        LazyVGrid(columns: gridItem, spacing: spacingWidth) {
            ForEach(assets, id: \.localIdentifier) { asset in
                PhotoCell(asset: asset)
                    .aspectRatio(1, contentMode: .fit)
                    .id(asset.localIdentifier)
            }
            
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    PhotoGridView(assets: .constant([]))
}


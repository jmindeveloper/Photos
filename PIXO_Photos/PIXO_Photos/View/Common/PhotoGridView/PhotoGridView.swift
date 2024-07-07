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
        ScrollViewReader { proxy in
            ScrollView(.vertical) {
                let gridItem = Array(
                    repeating: GridItem(.flexible(), spacing: spacingWidth),
                    count: columnItemCount
                )
                LazyVGrid(columns: gridItem, spacing: spacingWidth) {
                    ForEach(assets, id: \.localIdentifier) { asset in
                        PhotoCell(asset: asset)
                            .frame(height: getPhotoCellHeight())
                            .id(asset.localIdentifier)
                    }
                }
            }
            .onChange(of: assets) {
                 proxy.scrollTo(assets.last?.localIdentifier)
            }
        }
    }
    
    private func getPhotoCellHeight() -> CGFloat {
        let spacingWidth = (CGFloat(columnItemCount) - 1) * spacingWidth
        
        return (Constant.SCREEN_WIDTH - spacingWidth) / CGFloat(columnItemCount)
    }
}

@available(iOS 17.0, *)
#Preview {
    PhotoGridView(assets: .constant([]))
}


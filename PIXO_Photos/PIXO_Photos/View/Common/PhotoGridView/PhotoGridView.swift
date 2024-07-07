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
    
    var cellOnAppearAction: ((_ asset: PHAsset) -> Void)
    var cellOnDisappearAction: ((_ asset: PHAsset) -> Void)
    
    init(
        assets: Binding<[PHAsset]>,
        cellOnAppearAction: @escaping (_ asset: PHAsset) -> Void = { _ in },
        cellOnDisappearAction: @escaping (_ asset: PHAsset) -> Void = { _ in }
    ) {
        self._assets = assets
        self.cellOnAppearAction = cellOnAppearAction
        self.cellOnDisappearAction = cellOnDisappearAction
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
                    .onAppear {
                        cellOnAppearAction(asset)
                    }
                    .onDisappear {
                        cellOnDisappearAction(asset)
                    }
            }
            
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    PhotoGridView(assets: .constant([]))
}


//
//  PhotoStorageView.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/7/24.
//

import SwiftUI
import Photos

struct PhotoStorageView: View {
    @State var assets: [PHAsset] = []
    let library = PhotoLibrary()
    
    
    var body: some View {
        PhotoGridView(assets: $assets)
            .onAppear {
                let collection = library.getAllAssetCollections()
                let assets = library.getAssets(with: collection[0])
                self.assets = assets.assets
            }
    }
}

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
    let viewModel = PhotoStorageViewModel()
    
    
    var body: some View {
        PhotoGridView(assets: $assets)
    }
}

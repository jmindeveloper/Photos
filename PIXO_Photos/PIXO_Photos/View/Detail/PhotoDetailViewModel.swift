//
//  PhotoDetailViewModel.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/8/24.
//

import Foundation
import Photos

final class PhotoDetailViewModel: ObservableObject {
    @Published var assets: [PHAsset] = []
    @Published var currentItemIndex: Int
    
    init(assets: [PHAsset], currentItemIndex: Int) {
        self.assets = assets
        self.currentItemIndex = currentItemIndex
    }
}

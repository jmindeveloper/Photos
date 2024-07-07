//
//  PhotoStorageViewModel.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/7/24.
//

import Foundation
import Photos

final class PhotoStorageViewModel: ObservableObject {
    private let library = PhotoLibrary()
    private var recentsCollection: PHAssetCollection {
        if let collection = library.collections[.smartAlbum]?.first {
            return collection
        } else {
            fatalError("Recents collection을 찾지 못했습니다.")
        }
    }
    
    @Published var assets: [PHAsset] = []
    @Published var imageCount: Int = 0
    @Published var videoCount: Int = 0
    
    init() {
        assets = library.getAssets(with: recentsCollection).assets
        videoCount = assets.filter { $0.mediaType == .video }.count
        imageCount = assets.count - videoCount
    }
}

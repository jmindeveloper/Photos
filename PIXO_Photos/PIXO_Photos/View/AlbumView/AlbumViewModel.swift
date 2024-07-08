//
//  AlbumViewModel.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/8/24.
//

import Foundation
import Combine
import Photos

struct Album: Identifiable, Hashable {
    var id: String
    let title: String
    var assets: [PHAsset]
    var assetCount: Int
    let fetchResult: PHFetchResult<PHAsset>
}

final class AlbumViewModel: AlbumGridViewModelProtocol {
    let library: PhotoLibrary
    
    @Published var smartAlbum: [Album]
    @Published var userAlbum: [Album]
    
    private var subscriptions = Set<AnyCancellable>()
    
    init(library: PhotoLibrary) {
        self.library = library
        self.smartAlbum = library.collections[.smartAlbum]?.map { collection in
            let asset = library.getAssets(with: collection)
            return Album(
                id: collection.localIdentifier,
                title: collection.localizedTitle ?? "",
                assets: asset.assets,
                assetCount: asset.assets.count,
                fetchResult: asset.fetchResult
            )
        } ?? []
        
        self.userAlbum = library.collections[.album]?.map { collection in
            let asset = library.getAssets(with: collection)
            return Album(
                id: collection.localIdentifier,
                title: collection.localizedTitle ?? "",
                assets: asset.assets,
                assetCount: asset.assets.count,
                fetchResult: asset.fetchResult
            )
        } ?? []
        
        userAlbum.sort {
            $0.assets.last?.creationDate ?? Date() < $1.assets.last?.creationDate ?? Date()
        }
        
        // 최근항목
        userAlbum.insert(smartAlbum.removeFirst(), at: 0)
        binding()
    }
    
    private func binding() {
        library.addAssetsToAlbumPublisher
            .sink { [weak self] (collection, assets) in
                guard let self = self else { return }
                let index = userAlbum.firstIndex { $0.id == collection.localIdentifier }
                if let index = index {
                    userAlbum[index].assets.append(contentsOf: assets)
                    userAlbum[index].assetCount += assets.count
                }
            }.store(in: &subscriptions)
    }
    
    func creatAlbum(title: String) {
        library.createAlbum(withName: title) { [weak self] collection in
            guard let self = self else {
                return
            }
            let assets = library.getAssets(with: collection)
            userAlbum.append(
                Album(
                    id: collection.localIdentifier,
                    title: collection.localizedTitle ?? "",
                    assets: assets.assets,
                    assetCount: assets.assets.count,
                    fetchResult: assets.fetchResult
                )
            )
        }
    }
}

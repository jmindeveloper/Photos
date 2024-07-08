//
//  PhotoDetailViewModel.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/8/24.
//

import Foundation
import Combine
import UIKit
import Photos

final class PhotoDetailViewModel: AlbumGridViewModelProtocol {
    @Published var assets: [PHAsset] = [] {
        didSet {
            isAssetsCahnge = true
        }
    }
    var beforeItemIndex: Int = 0
    var currentItemIndex: Int {
        didSet {
            if currentItemIndex != oldValue {
                beforeItemIndex = oldValue
            }
            self.currentAsset = assets[currentItemIndex]
        }
    }
    @Published var currentAsset: PHAsset {
        didSet {
            if currentAsset.mediaType == .video {
                isPlayVideo = true
            }
        }
    }
    var isVideo: Bool {
        currentAsset.mediaType == .video
    }
    var isAssetsCahnge: Bool = false
    let library: PhotoLibrary
    
    @Published var isPlayVideo: Bool = false
    
    @Published var hiddenToolBar: Bool = false
    
    @Published var detailCollectionViewShowCellIndex: Int = 0 {
        didSet {
            detailScrollToItemBlock = true
            thumbnailScrollToItemBlock = false
        }
    }
    @Published var thumbnailCollectionViewShowCellIndex: Int = 0  {
        didSet {
            detailScrollToItemBlock = false
            thumbnailScrollToItemBlock = true
        }
    }
    @Published var userAlbum: [Album] = []
    
    private var subscriptions = Set<AnyCancellable>()
    
    var detailScrollToItemBlock: Bool = false
    var thumbnailScrollToItemBlock: Bool = false
    
    let detailScrollToItemPublisher = PassthroughSubject<Int, Never>()
    let thumbnailScrollToItemPublisher = PassthroughSubject<Int, Never>()
    
    init(assets: [PHAsset], library: PhotoLibrary, currentItemIndex: Int) {
        self.assets = assets
        self.library = library
        self.currentAsset = assets[currentItemIndex]
        self.currentItemIndex = currentItemIndex
        binding()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.detailScrollToItemPublisher.send(currentItemIndex)
            self?.thumbnailScrollToItemPublisher.send(currentItemIndex)
        }
        
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
    }
    
    // MARK: - Method
    private func binding() {
        $detailCollectionViewShowCellIndex
            .sink { [weak self] index in
                self?.currentItemIndex = index
                if self?.thumbnailScrollToItemBlock == false {
                    self?.thumbnailScrollToItemPublisher.send(index)
                }
            }.store(in: &subscriptions)
        
        $thumbnailCollectionViewShowCellIndex
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] index in
                self?.currentItemIndex = index
                if self?.detailScrollToItemBlock == false {
                    self?.detailScrollToItemPublisher.send(index)
                }
            }.store(in: &subscriptions)
        
        library.changeFavoriteAssetsPublisher
            .sink { [weak self] assets in
                guard let self = self else {
                    return
                }
                self.assets[currentItemIndex] = assets[0]
                self.currentAsset = assets[0]
            }.store(in: &subscriptions)
    }
    
    func getCurrentAssetImage(completion: @escaping ([UIImage]) -> Void) {
        library.requestImages(with: [currentAsset]) { images in
            completion(images)
        }
    }
    
    func deleteCurrentAsset() {
        library.deleteAssets(with: [currentAsset]) { [weak self] in
            guard let self = self else { return }
            assets.removeAll { $0 == self.currentAsset }
        }
    }
    
    func setFavoriteCurrentAsset() {
        library.favoriteAssets(with: [currentAsset])
    }
    
    func duplicateCurrentAssets() {
        library.duplicateAssets([currentAsset]) { [weak self] assets in
            self?.assets.append(contentsOf: assets)
        }
    }
    
    func copyCurrentImageToClipboard() {
        library.requestImages(with: [currentAsset]) { images in
            UIPasteboard.general.images = images
        }
    }
    
    func addAssetsToAlbum(albumName: String) {
        library.addAssetsToAlbum([currentAsset], to: albumName) { [weak self] in
            guard let self = self else { return }
            let albumIndex = userAlbum.firstIndex { $0.title == albumName }
            if let albumIndex = albumIndex {
                userAlbum[albumIndex].assets.append(currentAsset)
                userAlbum[albumIndex].assetCount += 1
            }
        }
    }
}

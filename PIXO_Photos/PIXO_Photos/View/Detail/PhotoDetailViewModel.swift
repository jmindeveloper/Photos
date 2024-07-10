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

protocol PhotoDetailViewModelProtocol: ObservableObject {
    var hiddenToolBar: Bool { get set }
    var currentAsset: PHAsset { get set }
    var isVideo: Bool { get }
    var isPlayVideo: Bool { get set }
    
    func duplicateCurrentAssets()
    func copyCurrentImageToClipboard()
    func addAssetsToAlbum(albumName: String)
    func setFavoriteCurrentAsset()
    func deleteCurrentAsset()
    func getCurrentAssetImage(completion: @escaping ([UIImage]) -> Void) 
}

final class PhotoDetailViewModel: NSObject, PhotoDetailViewModelProtocol, AlbumGridViewModelProtocol {
    @Published var assets: [PHAsset] = [] {
        didSet {
            isAssetsChange = true
        }
    }
    @Published var currentAsset: PHAsset {
        didSet {
            if currentAsset.mediaType == .video {
                isPlayVideo = true
            }
        }
    }
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
    
    private var fetchResult: PHFetchResult<PHAsset> = PHFetchResult()
    var isAssetsChange: Bool = false
    let library: PhotoLibrary
    var isVideo: Bool {
        currentAsset.mediaType == .video
    }
    var currentItemIndex: Int {
        didSet {
            if currentItemIndex >= assets.count {
                currentItemIndex = assets.count - 1
            }
            if currentItemIndex < 0 {
                currentItemIndex = 0
            }
            
            self.currentAsset = assets[currentItemIndex]
        }
    }
    var detailScrollToItemBlock: Bool = false
    var thumbnailScrollToItemBlock: Bool = false
    private var subscriptions = Set<AnyCancellable>()
    
    let detailScrollToItemPublisher = PassthroughSubject<Int, Never>()
    let thumbnailScrollToItemPublisher = PassthroughSubject<Int, Never>()
    
    init(assets: [PHAsset], library: PhotoLibrary, fetchResult: PHFetchResult<PHAsset>, currentItemIndex: Int) {
        self.assets = assets
        self.library = library
        self.currentAsset = assets[currentItemIndex]
        self.currentItemIndex = currentItemIndex
        self.fetchResult = fetchResult
        super.init()
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
        
        PHPhotoLibrary.shared().register(self)
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
        let index = assets.firstIndex(of: currentAsset)
        library.deleteAssets(with: [currentAsset]) { [weak self] in
            guard let self = self else { return }
            if let index = index {
                currentItemIndex = index - 1
            }
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

extension PhotoDetailViewModel: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let change = changeInstance.changeDetails(for: fetchResult)?.fetchResultAfterChanges else {
            return
        }
        fetchResult = change
        var asset = [PHAsset]()
        for i in 0..<change.count {
            asset.append(change[i])
        }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let beforeAssets = assets
            assets = asset
            
            if beforeAssets.count > asset.count {
                detailScrollToItemPublisher.send(currentItemIndex)
                thumbnailScrollToItemPublisher.send(currentItemIndex)
            }
        }
    }
}


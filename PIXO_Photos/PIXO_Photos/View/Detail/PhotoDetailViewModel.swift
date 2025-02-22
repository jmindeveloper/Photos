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
    var mainScrollToItemPublisher: PassthroughSubject<Int, Never> { get }
    var previewScrollToItemPublisher: PassthroughSubject<Int, Never> { get }
    var currentItemIndex: Int { get set }
    var mainCollectionViewShowCellIndex: Int { get set }
    var previewCollectionViewShowCellIndex: Int { get set }
    var assets: [PHAsset] { get set }
    var dateString: String { get }
    var currentAssetEXIF: [String: Any] { get set }
    var isAssetsChange: Bool { get set }
    
    func duplicateCurrentAssets()
    func copyCurrentImageToClipboard()
    func addAssetsToAlbum(albumName: String)
    func setFavoriteCurrentAsset()
    func deleteCurrentAsset()
    func getCurrentAssetImage(completion: @escaping ([UIImage]) -> Void) 
    func getEXIFData(completion: @escaping (() -> Void))
}

final class PhotoDetailViewModel: NSObject, PhotoDetailViewModelProtocol, AlbumGridViewModelProtocol {
    @Published var assets: [PHAsset] = [] {
        didSet {
            isAssetsChange = true
        }
    }
    @Published var currentAssetEXIF: [String : Any] = [:]
    @Published var currentAsset: PHAsset {
        didSet {
            if currentAsset == oldValue {
                return
            }
            if currentAsset.mediaType == .video {
                isPlayVideo = true
            }
        }
    }
    @Published var isPlayVideo: Bool = false
    @Published var hiddenToolBar: Bool = false
    @Published var mainCollectionViewShowCellIndex: Int = 0 {
        didSet {
            mainScrollToItemBlock = true
            previewScrollToItemBlock = false
        }
    }
    @Published var previewCollectionViewShowCellIndex: Int = 0  {
        didSet {
            mainScrollToItemBlock = false
            previewScrollToItemBlock = true
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
    var dateString: String {
        currentAsset.creationDate?.toMd() ?? ""
    }
    var mainScrollToItemBlock: Bool = false
    var previewScrollToItemBlock: Bool = false
    private var subscriptions = Set<AnyCancellable>()
    
    let mainScrollToItemPublisher = PassthroughSubject<Int, Never>()
    let previewScrollToItemPublisher = PassthroughSubject<Int, Never>()
    
    init(assets: [PHAsset], library: PhotoLibrary, fetchResult: PHFetchResult<PHAsset>, currentItemIndex: Int) {
        self.assets = assets
        self.library = library
        self.currentAsset = assets[currentItemIndex]
        self.currentItemIndex = currentItemIndex
        self.fetchResult = fetchResult
        super.init()
        binding()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.mainScrollToItemPublisher.send(currentItemIndex)
            self?.previewScrollToItemPublisher.send(currentItemIndex)
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
        $mainCollectionViewShowCellIndex
            .sink { [weak self] index in
                self?.currentItemIndex = index
                if self?.previewScrollToItemBlock == false {
                    self?.previewScrollToItemPublisher.send(index)
                }
            }.store(in: &subscriptions)
        
        $previewCollectionViewShowCellIndex
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] index in
                self?.currentItemIndex = index
                if self?.mainScrollToItemBlock == false {
                    self?.mainScrollToItemPublisher.send(index)
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
        library.requestImageURL(with: currentAsset) { url in
            guard let image = url.getUIImage() else {
                return
            }
            
            completion([image])
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
        library.duplicateAssets([currentAsset])
    }
    
    func copyCurrentImageToClipboard() {
        library.requestImageURL(with: currentAsset) { url in
            guard let image = url.getUIImage() else {
                return
            }
            
            UIPasteboard.general.images = [image]
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
    
    func getEXIFData(completion: @escaping () -> Void) {
        library.getEXIFData(asset: currentAsset) { [weak self] exif in
            self?.currentAssetEXIF = exif ?? [:]
            completion()
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
            if assets == asset { return }
            assets = asset
            
            if beforeAssets.count > asset.count {
                mainScrollToItemPublisher.send(currentItemIndex)
                previewScrollToItemPublisher.send(currentItemIndex)
            }
        }
    }
}


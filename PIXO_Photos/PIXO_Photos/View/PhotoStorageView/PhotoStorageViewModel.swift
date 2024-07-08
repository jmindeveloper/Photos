//
//  PhotoStorageViewModel.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/7/24.
//

import Foundation
import UIKit
import Combine
import Photos

protocol PhotoStorageViewModelProtocol: ObservableObject {
    var selectMode: Bool { get set }
    var imageCount: Int { get set }
    var videoCount: Int { get set }
    var assets: [PHAsset] { get set }
    var dateRangeString: String { get set }
    var selectedAssets: Set<PHAsset> { get set }
    var selectedAssetsTitle: String { get }
    var visibleAssetsDate: [Date] { get set }
    
    func duplicateSelectedAssets()
    func setFavoriteSelectedAssets()
    func copySelectedImageToClipboard()
    func addAssetsToAlbum(albumName: String)
    func getSelectedAssetsImage(completion: @escaping ([UIImage]) -> Void)
    func deleteSelectedAssets()
    func draggingAssetSelect(startLocation: CGPoint, currentLocation: CGPoint)
    func finishDraggingAssetSelect()
}

final class PhotoStorageViewModel: AssetDragSelectManager, PhotoStorageViewModelProtocol, PhotoGridViewModelProtocol, AlbumGridViewModelProtocol {
    
    let library: PhotoLibrary
    private var recentsCollection: PHAssetCollection {
        if let collection = library.collections[.smartAlbum]?.first {
            return collection
        } else {
            fatalError("Recents collection을 찾지 못했습니다.")
        }
    }
    private var fetchResult: PHFetchResult<PHAsset> = .init()
    
    @Published var assets: [PHAsset] = []
    @Published var imageCount: Int = 0
    @Published var videoCount: Int = 0
    @Published var dateRangeString: String = ""
    @Published var selectMode: Bool = false
    @Published var userAlbum: [Album] = []
    
    private var subscriptions = Set<AnyCancellable>()
    
    var visibleAssetsDate: [Date] = [] {
        didSet {
            dateRangeString = getDateRange(date1: visibleAssetsDate.min() ?? Date(), date2: visibleAssetsDate.max() ?? Date())
        }
    }
    
    var selectedAssetsTitle: String {
        selectedAssets.isEmpty ? "항목 선택" : "\(selectedAssets.count)개의 항목 선택됨"
    }
    
    init(library: PhotoLibrary) {
        self.library = library
        super.init()
        let fetchAssetResult = library.getAssets(with: recentsCollection)
        assets = fetchAssetResult.assets
        fetchResult = fetchAssetResult.fetchResult
        videoCount = assets.filter { $0.mediaType == .video }.count
        imageCount = assets.count - videoCount
        assetWithFrame = assets.map { ($0, .zero) }
        PHPhotoLibrary.shared().register(self)
        
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
        binding()
    }
    
    init(library: PhotoLibrary, album: Album) {
        self.library = library
        self.fetchResult = album.fetchResult
        super.init()
        self.assets = album.assets
        videoCount = assets.filter { $0.mediaType == .video }.count
        imageCount = assets.count - videoCount
        assetWithFrame = assets.map { ($0, .zero) }
        PHPhotoLibrary.shared().register(self)
        
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
        
        library.changeFavoriteAssetsPublisher
            .sink { [weak self] assets in
                guard let self = self else {
                    return
                }
                for asset in assets {
                    if let index = self.assets.firstIndex(of: asset) {
                        self.assets[index] = asset
                    }
                }
                objectWillChange.send()
            }.store(in: &subscriptions)
    }
    
    func getSelectedAssetsImage(completion: @escaping ([UIImage]) -> Void) {
        library.requestImages(with: Array(selectedAssets)) { images in
            completion(images)
        }
    }
    
    func deleteSelectedAssets() {
        library.deleteAssets(with: Array(selectedAssets)) { [weak self] in
            guard let self = self else { return }
            self.selectedAssets.removeAll()
        }
    }
    
    func setFavoriteSelectedAssets() {
        library.favoriteAssets(with: Array(selectedAssets)) { [weak self] assets in
            self?.selectedAssets.removeAll()
        }
    }
    
    func duplicateSelectedAssets() {
        library.duplicateAssets(Array(selectedAssets)) { [weak self] _ in
            self?.selectedAssets.removeAll()
        }
    }
    
    func copySelectedImageToClipboard() {
        library.requestImages(with: Array(selectedAssets)) { images in
            UIPasteboard.general.images = images
        }
    }
    
    func addAssetsToAlbum(albumName: String) {
        library.addAssetsToAlbum(Array(selectedAssets), to: albumName) { [weak self] in
            guard let self = self else { return }
            let albumIndex = userAlbum.firstIndex { $0.title == albumName }
            if let albumIndex = albumIndex {
                userAlbum[albumIndex].assets.append(contentsOf: Array(selectedAssets))
                userAlbum[albumIndex].assetCount += 1
            }
            selectMode = false
            selectedAssets.removeAll()
        }
    }
    
    private func getDateRange(date1: Date, date2: Date) -> String {
        let calendar = Calendar.current
        let date1Componets = calendar.dateComponents([.day, .month, .year], from: date1)
        let date2Componets = calendar.dateComponents([.day, .month, .year], from: date2)
        
        
        if date1Componets.year != date2Componets.year {
            // 년이 다를때
            return "\(date1Componets.year ?? 0)년 \(date1Componets.month ?? 0)월 \(date1Componets.day ?? 0)일 ~ \(date2Componets.year ?? 0)년 \(date2Componets.month ?? 0)월 \(date2Componets.day ?? 0)일"
        } else if date1Componets.month != date2Componets.month {
            // 월이 다를때
            return "\(date1Componets.year ?? 0)년 \(date1Componets.month ?? 0)월 \(date1Componets.day ?? 0)일 ~ \(date2Componets.month ?? 0)월 \(date2Componets.day ?? 0)일"
        } else if date1Componets.day != date2Componets.day {
            // 일이 다를때
            return "\(date1Componets.year ?? 0)년 \(date1Componets.month ?? 0)월 \(date1Componets.day ?? 0)일 ~ \(date2Componets.day ?? 0)일"
        } else {
            // 전부 같을때
            return "\(date1Componets.year ?? 0)년 \(date1Componets.month ?? 0)월 \(date1Componets.day ?? 0)일"
        }
    }
}

extension PhotoStorageViewModel: PHPhotoLibraryChangeObserver {
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
            assetWithFrame = asset.map { ($0, .zero) }
            assets = asset
            selectMode = false
        }
    }
}

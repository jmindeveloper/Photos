//
//  PhotoLibrary.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/7/24.
//

import UIKit
import Photos
import Combine

typealias FetchAssetResult = (assets: [PHAsset], fetchResult: PHFetchResult<PHAsset>)

final class PhotoLibrary {
    
    var collections: [PHAssetCollectionType: [PHAssetCollection]] = [:]
    var currentCollection: PHAssetCollection
    let addAssetsToAlbumPublisher = PassthroughSubject<(PHAssetCollection, [PHAsset]), Never>()
    let changeFavoriteAssetsPublisher = PassthroughSubject<[PHAsset], Never>()
    
    init() {
        self.currentCollection = PHAssetCollection()
        self.collections = getAllAssetCollections()
        self.currentCollection = collections[.smartAlbum]?.first ?? PHAssetCollection()
    }
    
    func getAllAssetCollections() -> [PHAssetCollectionType: [PHAssetCollection]] {
        var collections = [PHAssetCollectionType: [PHAssetCollection]]()
        
        // MARK: - smartAlbum
        let smartCollection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        
        for i in 0..<smartCollection.count {
            let asset = PHAsset.fetchAssets(in: smartCollection[i], options: nil)
            if asset.count != 0 {
                collections[.smartAlbum, default: []].append(smartCollection[i])
            }
        }
        
        // MARK: - UserAlbum
        let userAlbumCollection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        
        for i in 0..<userAlbumCollection.count {
            collections[.album, default: []].append(userAlbumCollection[i])
        }
        
        return collections
    }
    
    func getAssets(with collection: PHAssetCollection, fetchLimit: Int? = nil) -> FetchAssetResult {
        var assets = [PHAsset]()
        
        let fetchOption = PHFetchOptions()
        fetchOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        if let fetchLimit = fetchLimit {
            fetchOption.fetchLimit = fetchLimit
        }
        
        let fetchResult = PHAsset.fetchAssets(in: collection, options: fetchOption)
        
        for i in 0..<fetchResult.count {
            assets.append(fetchResult[i])
        }
        
        return (assets, fetchResult)
    }
    
    // video일경우 duration까지 받아옴
    static func requestImage(with asset: PHAsset?, completion: @escaping ((_ image: UIImage?, _ duration: Int?) -> Void)) {
        guard let asset = asset else {
            completion(nil, nil)
            return
        }
        
        let requestOption = PHImageRequestOptions()
        requestOption.isSynchronous = false
        requestOption.resizeMode = .none
        requestOption.deliveryMode = .highQualityFormat
        requestOption.isNetworkAccessAllowed = true
        let size = CGSize(width: 300, height: 300)
        
        PHCachingImageManager.default().requestImage(
            for: asset,
            targetSize: size,
            contentMode: .aspectFill,
            options: requestOption) { image, info in
                DispatchQueue.main.async {
                    if asset.mediaType == .video {
                        completion(image, Int(asset.duration))
                    } else if asset.mediaType == .image {
                        completion(image, nil)
                    }
                }
            }
    }
    
    func requestImages(with assets: [PHAsset], completion: @escaping (([UIImage]) -> Void)) {
        let dispatchGroup = DispatchGroup()
        var images: [UIImage] = []
        
        for asset in assets {
            dispatchGroup.enter()
            
            let requestOption = PHImageRequestOptions()
            requestOption.isSynchronous = false
            requestOption.resizeMode = .none
            requestOption.deliveryMode = .highQualityFormat
            requestOption.isNetworkAccessAllowed = true
            let size = CGSize(width: 300, height: 300)
            
            PHCachingImageManager.default().requestImage(
                for: asset,
                targetSize: size,
                contentMode: .aspectFill,
                options: requestOption) { image, info in
                    if let image = image {
                        images.append(image)
                    }
                    dispatchGroup.leave()
                }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(images)
        }
    }
    
    static func requestImageURL(with asset: PHAsset, completion: @escaping ((_ url: URL) -> Void)) {
        let options = PHContentEditingInputRequestOptions()
        options.isNetworkAccessAllowed = true
        
        asset.requestContentEditingInput(with: options) { input, info in
            if let input = input, let url = input.fullSizeImageURL {
                DispatchQueue.main.async {
                    completion(url)
                }
            }
        }
    }
    
    static func getData(with asset: PHAsset, completion: @escaping ((Data) -> Void)) {
        let option = PHImageRequestOptions()
        option.isNetworkAccessAllowed = true
        
        PHCachingImageManager.default().requestImageDataAndOrientation(for: asset, options: option) { data, _, _, _ in
            DispatchQueue.main.async {
                if let data = data {
                    DispatchQueue.main.async {
                        completion(data)
                    }
                }
            }
        }
    }
    
    static func getVideoAsset(with asset: PHAsset, completion: @escaping ((AVAsset) -> Void)) {
        if asset.mediaType == .video {
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true
            
            PHCachingImageManager.default().requestAVAsset(forVideo: asset, options: options) { asset, _, _ in
                if let asset = asset {
                    DispatchQueue.main.async {
                        completion(asset)
                    }
                }
            }
        }
    }
    
    func requedtVideoURL(with asset: PHAsset, completion: @escaping ((_ url: URL) -> Void)) {
        if asset.mediaType == .video {
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true
            
            PHCachingImageManager.default().requestAVAsset(forVideo: asset, options: options) { asset, _, _ in
                if let asset = asset as? AVURLAsset {
                    DispatchQueue.main.async {
                        completion(asset.url)
                    }
                } else {
                    fatalError("AVURLAsset 캐스팅 실패했습니다")
                }
            }
        } else {
            fatalError("asset의 mediaType이 video가 아닙니다")
        }
    }
    
    func deleteAssets(with assets: [PHAsset], completion: (() -> ())? = nil) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets(assets as NSArray)
        } completionHandler: { success, error in
            if success {
                DispatchQueue.main.async {
                    completion?()
                }
            } else if !success || error != nil {
                fatalError()
            }
        }
    }
    
    func favoriteAssets(with assets: [PHAsset], completion: (([PHAsset]) -> Void)? = nil) {
        PHPhotoLibrary.shared().performChanges {
            assets.forEach { asset in
                let request = PHAssetChangeRequest(for: asset)
                request.isFavorite = !asset.isFavorite
            }
        } completionHandler: { success, error in
            if success {
                let assetIDs = assets.map { $0.localIdentifier }
                let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: assetIDs, options: nil)
                var updatedAssets: [PHAsset] = []
                fetchResult.enumerateObjects { (asset, _, _) in
                    updatedAssets.append(asset)
                }
                DispatchQueue.main.async {
                    completion?(updatedAssets)
                    self.changeFavoriteAssetsPublisher.send(updatedAssets)
                }
            } else if !success || error != nil {
                fatalError()
            }
        }
    }
    
    private func duplicateAsset(_ asset: PHAsset, completion: ((PHAsset?) -> Void)? = nil) {
        PhotoLibrary.requestImage(with: asset) { [weak self] image, _ in
            guard let self = self,
                  let image = image else {
                fatalError("이미지 받아오기 실패")
            }
            
            self.saveImageToLibrary(image) { success, newAsset in
                completion?(newAsset)
            }
        }
    }
    
    func duplicateAssets(_ assets: [PHAsset], completion: (([PHAsset]) -> Void)? = nil) {
        let group = DispatchGroup()
        var newAssets: [PHAsset] = []
        
        for asset in assets {
            group.enter()
            duplicateAsset(asset) { newAsset in
                if let newAsset = newAsset {
                    newAssets.append(newAsset)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion?(newAssets)
        }
    }
    
    private func saveImageToLibrary(_ image: UIImage, completion: @escaping (Bool, PHAsset?) -> Void) {
        var placeholder: PHObjectPlaceholder?
        
        PHPhotoLibrary.shared().performChanges({
            let createAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            placeholder = createAssetRequest.placeholderForCreatedAsset
        }) { success, error in
            if success, let placeholder = placeholder {
                let assets = PHAsset.fetchAssets(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
                let asset = assets.firstObject
                DispatchQueue.main.async {
                    completion(true, asset)
                }
            } else {
                fatalError("이미지 저장 실패")
            }
        }
    }
    
    func createAlbum(withName name: String, completion: @escaping (PHAssetCollection) -> Void) {
        var placeholder: PHObjectPlaceholder?
        
        PHPhotoLibrary.shared().performChanges({
            let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
            placeholder = createAlbumRequest.placeholderForCreatedAssetCollection
        }, completionHandler: { success, error in
            DispatchQueue.main.async { [weak self] in
                if success {
                    guard let placeholder = placeholder else {
                        fatalError("앨범 생성 실패")
                    }
                    let fetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
                    guard let collection = fetchResult.firstObject else {
                        fatalError("앨범 생성 실패")
                    }
                    self?.collections[.album, default: []].append(collection)
                    completion(collection)
                } else {
                    fatalError("앨범 생성 실패")
                }
            }
        })
    }
    
    // 앨범에 에셋 추가
    func addAssetsToAlbum(_ assets: [PHAsset], to albumName: String, completion: (() -> Void)? = nil) {
        guard let collection = collections[.album]?.filter({ $0.localizedTitle == albumName }).first else {
            fatalError("앨범을 찾지 못했습니다")
        }
        
        PHPhotoLibrary.shared().performChanges({
            guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: collection) else {
                return
            }
            albumChangeRequest.addAssets(assets as NSFastEnumeration)
        }, completionHandler: { success, error in
            if success {
                DispatchQueue.main.async { [weak self] in
                    self?.addAssetsToAlbumPublisher.send((collection, assets))
                    completion?()
                }
            } else {
                fatalError("에셋 추가 실패")
            }
        })
    }
}

//
//  PhotoLibrary.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/7/24.
//

import UIKit
import Photos

typealias FetchAssetResult = (assets: [PHAsset], fetchResult: PHFetchResult<PHAsset>)

final class PhotoLibrary {
    
    var collections: [PHAssetCollectionType: [PHAssetCollection]] = [:]
    var currentCollection: PHAssetCollection
    
    init() {
        self.currentCollection = PHAssetCollection()
        self.collections = getAllAssetCollections()
        self.currentCollection = collections[.smartAlbum]?.first ?? PHAssetCollection()
        
        collections.forEach { _, v in
            v.forEach {
                print("collectionName --> ", $0.localizedTitle)
            }
        }
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
    
    func requestImageURL(with asset: PHAsset, completion: @escaping ((_ url: URL) -> Void)) {
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
    
    func favoriteAssets(with assets: [PHAsset], completion: (() -> Void)? = nil) {
        PHPhotoLibrary.shared().performChanges {
            assets.forEach { asset in
                let request = PHAssetChangeRequest(for: asset)
                request.isFavorite = !asset.isFavorite
            }
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
    
    func duplicateAssets(_ assets: [PHAsset], completion: (() -> Void)? = nil) {
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
            completion?()
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
}

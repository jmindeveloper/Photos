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
    
    func getAllAssetCollections() -> [PHAssetCollection] {
        var collections = [PHAssetCollection]()
    
        // MARK: - smartAlbum
        let smartCollection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
    
        for i in 0..<smartCollection.count {
            let asset = PHAsset.fetchAssets(in: smartCollection[i], options: nil)
            if asset.count != 0 {
                collections.append(smartCollection[i])
            }
        }
        
        // MARK: - UserAlbum
        let userAlbumCollection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        
        for i in 0..<userAlbumCollection.count {
            collections.append(userAlbumCollection[i])
        }
        
        return collections
    }
    
    func getAssets(with collection: PHAssetCollection, fetchLimit: Int? = nil) -> FetchAssetResult {
        var assets = [PHAsset]()
        
        let fetchOption = PHFetchOptions()
        fetchOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
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
    static func requestImage(with asset: PHAsset, completion: @escaping ((_ image: UIImage?, _ duration: Int?) -> Void)) {
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
    
    static func requedtVideoURL(with asset: PHAsset, completion: @escaping ((_ url: URL) -> Void)) {
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
}

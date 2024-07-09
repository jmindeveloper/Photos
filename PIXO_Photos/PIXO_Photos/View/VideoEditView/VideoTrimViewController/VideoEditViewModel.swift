//
//  VideoEditViewModel.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/9/24.
//

import Foundation
import Photos
import Combine
import AVFoundation

final class VideoEditViewModel: ObservableObject {
    var videoAsset: AVAsset? {
        didSet {
            if let videoAsset = videoAsset {
                videoAssetPublisher.send(videoAsset)
            }
        }
    }
    var asset: PHAsset
    
    let videoAssetPublisher = PassthroughSubject<AVAsset, Never>()
    
    init(asset: PHAsset) {
        self.asset = asset
        
        PhotoLibrary.getVideoAsset(with: asset) { [weak self] asset in
            self?.videoAsset = asset
        }
    }
}

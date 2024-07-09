//
//  VideoEditor.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/8/24.
//

import UIKit
import AVFoundation

final class VideoEditor {
    func getTimeLineImages(asset: AVAsset, count: Int, completion: @escaping (([UIImage]) -> Void)) {
        var count = count
        DispatchQueue.global().async {
            let avassetImageGenerator = AVAssetImageGenerator(asset: asset)
            avassetImageGenerator.appliesPreferredTrackTransform = true
            var images = [UIImage]()
            
            do {
                let duration = asset.duration.seconds
                var offset = duration / Double(count)
                if offset < 1 {
                    offset = 1
                    count = Int(duration)
                }
                
                var currentOffset = 0
                for _ in 0..<count {
                    let thumnailTime = CMTimeMake(value: Int64(currentOffset), timescale: 1)
                    if let cgThumbImage = try? avassetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) {
                        let thumbImage = UIImage(cgImage: cgThumbImage)
                        images.append(thumbImage)
                        currentOffset += Int(offset)
                    }
                }
                
                DispatchQueue.main.async {
                    completion(images)
                }
            } catch {
                fatalError()
            }
        }
    }
}

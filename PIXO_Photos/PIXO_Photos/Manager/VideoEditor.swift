//
//  VideoEditor.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/8/24.
//

import UIKit
import Photos
import AVFoundation

final class VideoEditor {
    func getTimeLineImages(asset: AVAsset, count: Int, completion: @escaping (([UIImage]) -> Void)) {
        var count = count
        DispatchQueue.global().async {
            let avassetImageGenerator = AVAssetImageGenerator(asset: asset)
            avassetImageGenerator.appliesPreferredTrackTransform = true
            var images = [UIImage]()
            
            let duration = asset.duration.seconds
            if duration < CGFloat(count) {
                count = Int(duration)
            }
            var offset = duration / Double(count)
            if offset < 1 {
                offset = 1
                count = Int(duration)
            }
            
            var currentOffset: CGFloat = 0
            for _ in 0..<count {
                let thumnailTime = CMTimeMakeWithSeconds(currentOffset, preferredTimescale: Int32(NSEC_PER_SEC))
                if let cgThumbImage = try? avassetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) {
                    let thumbImage = UIImage(cgImage: cgThumbImage)
                    images.append(thumbImage)
                    currentOffset += offset
                }
            }
            
            DispatchQueue.main.async {
                completion(images)
            }
        }
    }
    
    func exportVideo(asset: AVAsset, filter: FilterValue?, startTime: CMTime, endTime: CMTime, completion: @escaping (() -> Void)) {
        let timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: endTime)
        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
        let fileManager = FileManager.default
        
        let outputURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("EditVideo.mp4")
        
        if fileManager.fileExists(atPath: outputURL.path) {
            try? fileManager.removeItem(at: outputURL)
        }
        
        exporter?.outputURL = outputURL
        exporter?.outputFileType = .mp4
        exporter?.timeRange = timeRange
        exporter?.exportAsynchronously { [weak self] in
            DispatchQueue.main.async {
                if let error = exporter?.error {
                    fatalError("video export 실패, \(error.localizedDescription)")
                } else {
                    self?.saveVideoToPhotoLibrary(outputURL, filter: filter) {
                        completion()
                    }
                }
            }
        }
    }
    
    private func saveVideoToPhotoLibrary(_ videoURL: URL, filter: FilterValue?, completion: @escaping (() -> Void)) {
        PhotoLibrary.saveVideoToLibrary(videoURL, filter: filter) {
            completion()
        }
    }
}

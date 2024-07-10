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
    var context = CIContext()
    
    func getTimeLineImages(asset: AVAsset, count: Int, completion: @escaping (([UIImage]) -> Void)) {
        print("getTimeLine")
        var count = count
        DispatchQueue.global().async {
            let avassetImageGenerator = AVAssetImageGenerator(asset: asset)
            avassetImageGenerator.appliesPreferredTrackTransform = true
            var images = [UIImage]()
            
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
        }
    }
    
    func exportTrimVideo(asset: AVAsset, startTime: CMTime, endTime: CMTime, completion: @escaping (() -> Void)) {
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
                    self?.saveVideoToPhotoLibrary(outputURL) {
                        completion()
                    }
                }
            }
        }
    }
    
    private func saveVideoToPhotoLibrary(_ videoURL: URL, completion: @escaping (() -> Void)) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
        }) { success, error in
            if let error = error {
                fatalError("video 저장 실패, \(error.localizedDescription)")
            }
            completion()
        }
    }
    
    
    
    
    
    
    
    
    //    private func applyFilter(to image: CIImage, filter: Filter) -> CIImage? {
    //        let filterName: String
    //        switch filter {
    //        case .Original:
    //            return image
    //        case .Mono:
    //            filterName = "CIPhotoEffectMono"
    //        case .Tonal:
    //            filterName = "CIPhotoEffectTonal"
    //        case .Noir:
    //            filterName = "CIPhotoEffectNoir"
    //        case .Fade:
    //            filterName = "CIPhotoEffectFade"
    //        case .Chrome:
    //            filterName = "CIPhotoEffectChrome"
    //        case .Process:
    //            filterName = "CIPhotoEffectProcess"
    //        case .Transfer:
    //            filterName = "CIPhotoEffectTransfer"
    //        case .Instant:
    //            filterName = "CIPhotoEffectInstant"
    //        }
    //
    //        let filter = CIFilter(name: filterName)
    //        filter?.setValue(image, forKey: kCIInputImageKey)
    //        return filter?.outputImage
    //    }
    //
    //    private func applyAdjustEffect(to image: CIImage, effect: AdjustEffect, value: Float) -> CIImage? {
    //        let filter: CIFilter
    //        switch effect {
    //        case .Exposure:
    //            filter = CIFilter(name: "CIExposureAdjust")!
    //            filter.setValue(value, forKey: kCIInputEVKey)
    //        case .Saturation:
    //            filter = CIFilter(name: "CIColorControls")!
    //            filter.setValue(value, forKey: kCIInputSaturationKey)
    //        case .Hue:
    //            filter = CIFilter(name: "CIHueAdjust")!
    //            filter.setValue(value, forKey: kCIInputAngleKey)
    //        case .Brightness:
    //            filter = CIFilter(name: "CIColorControls")!
    //            filter.setValue(value, forKey: kCIInputBrightnessKey)
    //        case .Contrast:
    //            filter = CIFilter(name: "CIColorControls")!
    //            filter.setValue(value, forKey: kCIInputContrastKey)
    //        case .Highlights:
    //            filter = CIFilter(name: "CIHighlightShadowAdjust")!
    //            filter.setValue(value, forKey: "inputHighlightAmount")
    //        case .Shadows:
    //            filter = CIFilter(name: "CIHighlightShadowAdjust")!
    //            filter.setValue(value, forKey: "inputShadowAmount")
    //        case .Temperature:
    //            filter = CIFilter(name: "CITemperatureAndTint")!
    //            filter.setValue(CIVector(x: CGFloat(value), y: 0), forKey: "inputNeutral")
    //        case .Sharpness:
    //            filter = CIFilter(name: "CISharpenLuminance")!
    //            filter.setValue(value, forKey: kCIInputSharpnessKey)
    //        }
    //
    //        filter.setValue(image, forKey: kCIInputImageKey)
    //        return filter.outputImage
    //    }
    //
    //    private func applyEffects(to frame: CIImage, filter: Filter, effects: [(AdjustEffect, Float)]) -> CIImage? {
    //        var filteredImage = applyFilter(to: frame, filter: filter)
    //        for (effect, value) in effects {
    //            if let image = filteredImage {
    //                filteredImage = applyAdjustEffect(to: image, effect: effect, value: value)
    //            }
    //        }
    //        return filteredImage
    //    }
    //
    //    func exportVideo(asset: AVAsset, filter: Filter, effects: [(AdjustEffect, Float)], completion: @escaping (Bool) -> Void) {
    //        guard let reader = try? AVAssetReader(asset: asset) else {
    //            fatalError()
    //            return
    //        }
    //
    //        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
    //            fatalError()
    //            return
    //        }
    //
    //        let readerOutputSettings: [String: Any] = [
    //            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB
    //        ]
    //        let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: readerOutputSettings)
    //        reader.add(readerOutput)
    //
    //        let outputURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("EditVideo.mov")
    //
    //        if FileManager.default.fileExists(atPath: outputURL.path) {
    //            try? FileManager.default.removeItem(at: outputURL)
    //        }
    //
    //        let writer = try! AVAssetWriter(outputURL: outputURL, fileType: .mp4)
    //        let writerInputSettings: [String: Any] = [
    //            AVVideoCodecKey: AVVideoCodecType.h264,
    //            AVVideoWidthKey: videoTrack.naturalSize.width,
    //            AVVideoHeightKey: videoTrack.naturalSize.height
    //        ]
    //        let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: writerInputSettings)
    //        writer.add(writerInput)
    //
    //        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: nil)
    //
    //        reader.startReading()
    //        writer.startWriting()
    //        writer.startSession(atSourceTime: .zero)
    //
    //        let processingQueue = DispatchQueue(label: "videoProcessingQueue")
    //
    //        writerInput.requestMediaDataWhenReady(on: processingQueue) {
    //            while writerInput.isReadyForMoreMediaData {
    //                if let sampleBuffer = readerOutput.copyNextSampleBuffer(),
    //                   let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
    //                    let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
    //                    let processedImage = self.applyEffects(to: ciImage, filter: filter, effects: effects)
    //                    var newPixelBuffer: CVPixelBuffer?
    //
    //                    CVPixelBufferCreate(
    //                        kCFAllocatorDefault,
    //                        Int(videoTrack.naturalSize.width),
    //                        Int(videoTrack.naturalSize.height),
    //                        kCVPixelFormatType_32ARGB,
    //                        nil,
    //                        &newPixelBuffer
    //                    )
    //
    //                    if let newPixelBuffer = newPixelBuffer, let processedImage = processedImage {
    //                        self.context.render(processedImage, to: newPixelBuffer)
    //                        pixelBufferAdaptor.append(newPixelBuffer, withPresentationTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
    //                    }
    //                } else {
    //                    writerInput.markAsFinished()
    //                    writer.finishWriting {
    //                        if writer.status == .completed {
    //                            self.saveVideoToPhotoLibrary(outputURL) { success in
    //                                if success {
    //                                    self.deleteFile(at: outputURL)
    //                                }
    //                                completion(success)
    //                            }
    //                        } else {
    //                            fatalError()
    //                        }
    //                    }
    //                    break
    //                }
    //            }
    //        }
    //    }
    //
    //
    //    private func deleteFile(at url: URL) {
    //        do {
    //            try FileManager.default.removeItem(at: url)
    //            print("File deleted successfully.")
    //        } catch {
    //            print("Failed to delete file: \(error)")
    //        }
    //    }
}

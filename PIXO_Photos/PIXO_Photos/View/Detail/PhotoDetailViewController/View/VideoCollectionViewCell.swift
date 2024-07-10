//
//  VideoCollectionViewCell.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/8/24.
//

import UIKit
import Photos
import AVFoundation
import Combine

final class VideoCollectionViewCell: UICollectionViewCell {
    static let identifier = "VideoCollectionViewCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let videoView: UIView = {
        let view = UIView()
        view.isHidden = true
        
        return view
    }()
        
    var assetId: String?
    var videoAsset: AVAsset?
    var player: AVPlayer?
    private var playerLayer = AVPlayerLayer()
    private var subscriptions = Set<AnyCancellable>()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isStartVideo = false
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stopVideo()
        isStartVideo = false
        videoAsset = nil
    }
    
    func startVideo() {
        if isStartVideo { return }
        stopVideo()
        if let videoAsset = videoAsset {
            isStartVideo = true
            videoView.isHidden = false
            let item = AVPlayerItem(asset: videoAsset)
            player = AVPlayer(playerItem: item)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = videoView.bounds
            playerLayer.videoGravity = .resizeAspect
            playerLayer.backgroundColor = UIColor.systemBackground.cgColor
            videoView.layer.addSublayer(playerLayer)
            
            if let filter = VideoFilterStorage.getFilter(id: assetId ?? "") {
                setFilter(filter: filter, playerItem: item)
            }
            
            player?.play()
            NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
                .sink { [weak self] _ in
                    self?.stopVideo()
                }.store(in: &subscriptions)
        }
    }
    
    func pauseVideo() {
        player?.pause()
    }
    
    func playVideo() {
        if !isStartVideo {
            startVideo()
        } else {
            player?.play()
        }
    }
    
    func stopVideo() {
        player?.pause()
        isStartVideo = false
        videoView.isHidden = true
    }
    
    private func setSubViews() {
        [imageView, videoView].forEach {
            contentView.addSubview($0)
        }
        
        setConstraints()
    }
    
    private func setConstraints() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        videoView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setImage(image: UIImage?) {
        imageView.image = image
    }
    
    func setVideoAsset(asset: AVAsset) {
        videoAsset = asset
    }
    
    private func setFilter(filter: FilterValue, playerItem: AVPlayerItem) {
        let videoComposition = AVVideoComposition(asset: playerItem.asset) { [weak self] request in
            guard let self = self else { return }
            let source = request.sourceImage.clampedToExtent()
            
            var filteredImage = source
            
            // Apply sharpness
            if let sharpness = filter["sharpness"], sharpness != 0.0 {
                if let sharpnessFilter = CIFilter(name: "CISharpenLuminance") {
                    sharpnessFilter.setValue(filteredImage, forKey: kCIInputImageKey)
                    sharpnessFilter.setValue(sharpness, forKey: kCIInputSharpnessKey)
                    if let output = sharpnessFilter.outputImage {
                        filteredImage = output
                    }
                }
            }
            
            // Apply exposure
            if let exposure = filter["exposure"] {
                if let exposureFilter = CIFilter(name: "CIExposureAdjust") {
                    exposureFilter.setValue(filteredImage, forKey: kCIInputImageKey)
                    exposureFilter.setValue(exposure, forKey: kCIInputEVKey)
                    if let output = exposureFilter.outputImage {
                        filteredImage = output
                    }
                }
            }
            
            // Apply brightness, contrast, and saturation
            if let brightness = filter["brightness"],
               let contrast = filter["contrast"],
               let saturation = filter["saturation"] {
                if let colorControlsFilter = CIFilter(name: "CIColorControls") {
                    colorControlsFilter.setValue(filteredImage, forKey: kCIInputImageKey)
                    colorControlsFilter.setValue(brightness, forKey: kCIInputBrightnessKey)
                    colorControlsFilter.setValue(contrast, forKey: kCIInputContrastKey)
                    colorControlsFilter.setValue(saturation, forKey: kCIInputSaturationKey)
                    if let output = colorControlsFilter.outputImage {
                        filteredImage = output
                    }
                }
            }
            
            // Apply hue adjustment
            if let hue = filter["hue"] {
                if let hueAdjustFilter = CIFilter(name: "CIHueAdjust") {
                    hueAdjustFilter.setValue(filteredImage, forKey: kCIInputImageKey)
                    hueAdjustFilter.setValue(hue, forKey: kCIInputAngleKey)
                    if let output = hueAdjustFilter.outputImage {
                        filteredImage = output
                    }
                }
            }
            
            // Apply temperature
            if let temperature = filter["temperature"] {
                if let temperatureFilter = CIFilter(name: "CITemperatureAndTint") {
                    temperatureFilter.setValue(filteredImage, forKey: kCIInputImageKey)
                    let neutral = CIVector(x: CGFloat(temperature), y: 0.0)
                    temperatureFilter.setValue(neutral, forKey: "inputNeutral")
                    if let output = temperatureFilter.outputImage {
                        filteredImage = output
                    }
                }
            }
            
            let photoFilter = Filter.intToValue(Int(filter["filter"] ?? 0))
            filteredImage = applyPhotoFilter(photoFilter, to: filteredImage)
            
            let output = filteredImage.cropped(to: request.sourceImage.extent)
            request.finish(with: output, context: nil)
        }
        
        playerItem.videoComposition = videoComposition
    }
    
    func applyPhotoFilter(_ filter: Filter, to image: CIImage) -> CIImage {
        switch filter {
        case .Original:
            return image
        case .Mono:
            return image.applyingFilter("CIPhotoEffectMono")
        case .Tonal:
            return image.applyingFilter("CIPhotoEffectTonal")
        case .Noir:
            return image.applyingFilter("CIPhotoEffectNoir")
        case .Fade:
            return image.applyingFilter("CIPhotoEffectFade")
        case .Chrome:
            return image.applyingFilter("CIPhotoEffectChrome")
        case .Process:
            return image.applyingFilter("CIPhotoEffectProcess")
        case .Transfer:
            return image.applyingFilter("CIPhotoEffectTransfer")
        case .Instant:
            return image.applyingFilter("CIPhotoEffectInstant")
        }
    }
}

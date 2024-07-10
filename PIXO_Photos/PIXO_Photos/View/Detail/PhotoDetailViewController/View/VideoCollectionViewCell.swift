//
//  VideoCollectionViewCell.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/8/24.
//

import UIKit
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
    
    private var isStartVideo = false
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stopVideo()
        isStartVideo = false
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
}

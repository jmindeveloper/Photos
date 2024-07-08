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
    private var player: AVPlayer?
    private var playerLayer = AVPlayerLayer()
    private var subscriptions = Set<AnyCancellable>()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var isPlayVideo = false
    private var playVideoDate: Date?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isPlayVideo = false
        playVideoDate = nil
    }
    
    func playVideo() {
        if let videoAsset = videoAsset {
            isPlayVideo = true
            playVideoDate = Date()
            videoView.isHidden = false
            let item = AVPlayerItem(asset: videoAsset)
            player = AVPlayer(playerItem: item)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = videoView.bounds
            playerLayer.videoGravity = .resizeAspectFill
            videoView.layer.addSublayer(playerLayer)
            player?.play()
            NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
                .sink { [weak self] _ in
                    self?.stopVideo()
                }.store(in: &subscriptions)
        }
    }
    
    func stopVideo() {
        player?.pause()
        videoView.isHidden = true
        if isPlayVideo {
            let asset = videoAsset as? AVURLAsset
            let urlString = asset?.url.absoluteString
            let fileName = urlString?.components(separatedBy: "%2F").last?.components(separatedBy: "?").first
        }
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

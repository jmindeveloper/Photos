//
//  VideoView.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/9/24.
//

import UIKit
import AVFoundation
import Combine

final class VideoView: UIView {
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    let videoIntervalPublisher = PassthroughSubject<(Double, CMTime), Never>()
    var subscriptions = Set<AnyCancellable>()
    
    var item: AVPlayerItem? {
        return player?.currentItem
    }
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setAsset(asset: AVAsset) {
        player = AVPlayer(playerItem: AVPlayerItem(asset: asset))
        player?.volume = 1
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect
        playerLayer?.masksToBounds = false
        playerLayer?.frame = bounds
        
        observeVideo()
        layer.addSublayer(playerLayer ?? CALayer())
    }
    
    func start() {
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: item)
            .sink { [weak self] _ in
                self?.player?.seek(to: .zero)
                self?.stop()
            }.store(in: &subscriptions)
        
        player?.play()
    }
    
    func stop() {
        player?.pause()
    }
    
    private func observeVideo() {
        let interval = CMTimeMake(value: 1, timescale: 60)
        player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            videoIntervalPublisher.send((time.seconds, player?.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1)))
        }
    }
}

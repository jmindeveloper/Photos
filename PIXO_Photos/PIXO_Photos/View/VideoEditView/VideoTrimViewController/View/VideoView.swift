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
    
    private var startTime: CMTime = CMTime(value: 0, timescale: 1)
    private var endTime: CMTime?
    
    let videoIntervalPublisher = PassthroughSubject<(Double, CMTime), Never>()
    let finishVideoPublisher = PassthroughSubject<Void, Never>()
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
        playerLayer?.frame = bounds
    }
    
    func setAsset(asset: AVAsset) {
        player = AVPlayer(playerItem: AVPlayerItem(asset: asset))
        player?.volume = 1
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect
        playerLayer?.masksToBounds = false
        playerLayer?.frame = bounds
        endTime = player?.currentItem?.duration
        
        observeVideo()
        layer.addSublayer(playerLayer ?? CALayer())
    }
    
    func start() {
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: item)
            .sink { [weak self] _ in
                guard let self = self else { return }
                player?.seek(to: startTime)
                stop()
            }.store(in: &subscriptions)
        
        player?.play()
    }
    
    func stop() {
        player?.pause()
    }
    
    func seek(time: CMTime) {
        player?.seek(to: time, completionHandler: { _ in })
    }
    
    func setStartTime(offset: CGFloat, completion: @escaping ((CMTime) -> Void)) {
        let startTime = (player?.currentItem?.duration.seconds ?? 0) * offset
        let time = CMTimeMakeWithSeconds(startTime, preferredTimescale: Int32(NSEC_PER_SEC))
        self.startTime = time
        
        player?.seek(to: time)
        
        completion(time)
    }
    
    func setEndTime(offset: CGFloat, completion: @escaping ((CMTime) -> Void)) {
        let endTime = (player?.currentItem?.duration.seconds ?? 0) * offset
        let time = CMTimeMakeWithSeconds(endTime, preferredTimescale: Int32(NSEC_PER_SEC))
        self.endTime = time
        
        player?.seek(to: time)
        completion(time)
    }
    
    private func observeVideo() {
        let interval = CMTimeMake(value: 1, timescale: 60)
        player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            videoIntervalPublisher.send((time.seconds, player?.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1)))
            let endTimeSecondsFloat = CMTimeGetSeconds(endTime ?? CMTimeMake(value: 1, timescale: 1))
            let currentTime = player?.currentItem?.currentTime().seconds ?? 0
            if currentTime > endTimeSecondsFloat {
                finishVideoPublisher.send()
                player?.seek(to: startTime)
                stop()
            }
        }
    }
}

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

protocol VideoEditViewModelProtocol: ObservableObject, FilterManagerProtocol {
    var editMode: VideoEditViewModel.EditMode { get set }
    var editAsset: PHAsset { get set }
    var videoAssetPublisher: PassthroughSubject<AVAsset, Never> { get }
    var startTime: CMTime { get set }
    var endTime: CMTime? { get set }
    
    func saveVideo(completion: @escaping (() -> Void))
    func getVideoAsset()
}

final class VideoEditViewModel: FilterManager, VideoEditViewModelProtocol {
    enum EditMode: CaseIterable {
        case Trim
        case Adjust
        case Filter
        
        var imageName: String {
            switch self {
            case .Trim:
                return "video.fill"
            case .Filter:
                return "camera.filters"
            case .Adjust:
                return "slider.horizontal.3"
            }
        }
        
        var title: String {
            switch self {
            case .Trim:
                return "비디오"
            case .Filter:
                return "필터"
            case .Adjust:
                return "조절"
            }
        }
    }
    
    @Published var editMode: EditMode = .Trim
    @Published var editAsset: PHAsset
    
    private let videoEditor = VideoEditor()
    var videoAsset: AVAsset? {
        didSet {
            if let videoAsset = videoAsset {
                videoAssetPublisher.send(videoAsset)
            }
        }
    }
    
    var startTime: CMTime = CMTimeMake(value: 0, timescale: 1)
    var endTime: CMTime?
    
    private var isLoadHistory: Bool = false
    
    let videoAssetPublisher = PassthroughSubject<AVAsset, Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    init(editAsset: PHAsset) {
        self.editAsset = editAsset
        super.init()
        getVideoAsset()
    }
    
    private func binding() {
        $saturation
            .merge(with: $hue)
            .merge(with: $exposure)
            .merge(with: $brightness)
            .merge(with: $contrast)
            .merge(with: $highlights)
            .merge(with: $shadows)
            .merge(with: $temperature)
            .merge(with: $sharpness)
            .combineLatest($currentFilter)
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else {
                    return
                }
                if isLoadHistory {
                    isLoadHistory = false
                    return
                }
                saveHistory()
                forwardHistory.removeAll()
            }.store(in: &subscriptions)
    }
    
    func getVideoAsset() {
        if let asset = videoAsset {
            videoAssetPublisher.send(asset)
            return
        }
        PhotoLibrary.getVideoAsset(with: editAsset) { [weak self] asset in
            self?.videoAsset = asset
            self?.endTime = AVPlayerItem(asset: asset).duration
        }
    }
    
    func saveVideo(completion: @escaping (() -> Void)) {
        guard let asset = videoAsset,
              let endTime = endTime else {
            return
        }
        
        videoEditor.exportTrimVideo(
            asset: asset,
            filter: backwardHistoryEmpty ? nil : backwardHistory.last ?? [:],
            startTime: startTime,
            endTime: endTime
        ) {
            completion()
        }
    }
}

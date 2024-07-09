//
//  VideoTrimViewController.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/9/24.
//

import UIKit
import Combine
import AVFoundation

final class VideoTrimViewController: UIViewController {
    
    // MARK: - setSubViews
    private lazy var videoView: VideoView = {
        let view = VideoView()
        
        return view
    }()
    
    private lazy var videoTrimTimeLineView: VideoTrimTimeLineView = {
        let view = VideoTrimTimeLineView()
        
        return view
    }()
    
    // MARK: - Properties
    private var viewModel: VideoEditViewModel?
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSubViews()
        binding()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoView.stop()
    }
    
    // MARK: - setSubViews
    private func setSubViews() {
        [videoView, videoTrimTimeLineView].forEach {
            view.addSubview($0)
        }
        
        setConstraints()
    }
    
    private func setConstraints() {
        videoView.snp.makeConstraints {
            $0.horizontalEdges.top.equalToSuperview()
        }
        
        videoTrimTimeLineView.snp.makeConstraints {
            $0.top.equalTo(videoView.snp.bottom).offset(30)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(60)
            $0.bottom.equalToSuperview().offset(-30)
        }
    }
    
    // MARK: - Method
    private func binding() {
        viewModel?.videoAssetPublisher
            .sink { [weak self] asset in
                self?.videoView.setAsset(asset: asset)
                self?.videoTrimTimeLineView.setTimeLineView(asset: asset)
                self?.videoView.start()
            }.store(in: &subscriptions)
        
        videoView.videoIntervalPublisher
            .sink { [weak self] current, total in
                self?.videoTrimTimeLineView.setTimeLinePosition(currentTime: current, totalTime: total)
            }.store(in: &subscriptions)
        
        videoTrimTimeLineView.seekPublisher
            .sink { [weak self] time in
                self?.videoView.seek(time: time)
            }.store(in: &subscriptions)
    }
    
    func setViewModel(viewModel: VideoEditViewModel) {
        self.viewModel = viewModel
    }
}

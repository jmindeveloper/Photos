//
//  VideoTrimTimeLineView.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/9/24.
//

import UIKit
import Combine
import SnapKit
import AVFoundation

final class VideoTrimTimeLineView: UIView {
    // MARK: - ViewProperties
    private let baseView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        
        return view
    }()
    
    private let playPauseButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGray4
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.setImage(UIImage(systemName: "pause.fill"), for: .selected)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white, for: .selected)
        
        return button
    }()
    
    private let startPositionView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "chevron.left")
        view.isUserInteractionEnabled = true
        view.tintColor = .white
        view.backgroundColor = .brown
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let endPositionView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "chevron.right")
        view.isUserInteractionEnabled = true
        view.tintColor = .white
        view.backgroundColor = .brown
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let trimPositionView: UIView = {
        let view = UIView()
        view.backgroundColor = .brown
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let timeLineView: VideoTimeLineView = VideoTimeLineView()
    
    private var startPositionOffset: NSLayoutConstraint?
    private var endPositionOffset: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setSubViews()
        connectTarget()
        binding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    private var subscriptions = Set<AnyCancellable>()
    let seekPublisher = PassthroughSubject<CMTime, Never>()
    
    // MARK: - setSubViews
    private func setSubViews() {
        [baseView, playPauseButton, trimPositionView, timeLineView,
         startPositionView, endPositionView].forEach {
            addSubview($0)
        }
        
        [].forEach {
            baseView.addSubview($0)
        }
        
        setConstraints()
    }
    
    private func setConstraints() {
        playPauseButton.snp.makeConstraints {
            $0.verticalEdges.leading.equalToSuperview()
            $0.width.equalTo(playPauseButton.snp.height)
        }
        
        baseView.snp.makeConstraints {
            $0.leading.equalTo(playPauseButton.snp.trailing).offset(1)
            $0.verticalEdges.trailing.equalToSuperview()
        }
        
        timeLineView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(4)
            $0.horizontalEdges.equalTo(baseView).inset(25)
        }
        
        startPositionOffset = startPositionView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor)
        endPositionOffset = endPositionView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor)
        
        NSLayoutConstraint.activate([
            startPositionOffset!,
            endPositionOffset!,
            startPositionView.widthAnchor.constraint(equalToConstant: 25),
            endPositionView.widthAnchor.constraint(equalToConstant: 25),
            startPositionView.topAnchor.constraint(equalTo: baseView.topAnchor),
            startPositionView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor),
            endPositionView.topAnchor.constraint(equalTo: baseView.topAnchor),
            endPositionView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor),
            trimPositionView.leadingAnchor.constraint(equalTo: startPositionView.leadingAnchor),
            trimPositionView.trailingAnchor.constraint(equalTo: endPositionView.trailingAnchor),
            trimPositionView.topAnchor.constraint(equalTo: startPositionView.topAnchor),
            trimPositionView.bottomAnchor.constraint(equalTo: endPositionView.bottomAnchor)
        ])
    }
    
    // MARK: - binding
    private func binding() {
        timeLineView.seekPublisher
            .sink { [weak self] time in
                self?.seekPublisher.send(time)
            }.store(in: &subscriptions)
    }
    
    // MARK: - connectTarget
    private func connectTarget() {
        let startPositionGesture = UIPanGestureRecognizer(target: self, action: #selector(startPositionPanGesture(_:)))
        startPositionView.addGestureRecognizer(startPositionGesture)
        
        let endPositionGesture = UIPanGestureRecognizer(target: self, action: #selector(endPositionPanGesture(_:)))
        endPositionView.addGestureRecognizer(endPositionGesture)
    }
    
    @objc private func startPositionPanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: startPositionView)
        
        let moveX = translation.x
        
        if trimPositionView.frame.width < 60, moveX > 0 { return }
        
        if startPositionOffset?.constant ?? 0 < 0 {
            startPositionOffset?.constant = 0
        }
        
        startPositionOffset?.constant += moveX
        
        sender.setTranslation(CGPoint.zero, in: startPositionView)
    }
    
    @objc private func endPositionPanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: endPositionView)
        
        let moveX = translation.x
        
        if trimPositionView.frame.width < 60, moveX < 0 { return }
        
        if endPositionOffset?.constant ?? 0 > 0 {
            endPositionOffset?.constant = 0
        }
        
        endPositionOffset?.constant += moveX
        
        sender.setTranslation(CGPoint.zero, in: endPositionView)
    }
    
    // MARK: - Method
    func setTimeLineView(asset: AVAsset) {
        timeLineView.setTimeLineView(asset: asset, completion: { })
    }
    
    func setTimeLinePosition(currentTime: Double, totalTime: CMTime) {
        timeLineView.setTimeLinePosition(currentTime: currentTime, totalTime: totalTime)
    }
}

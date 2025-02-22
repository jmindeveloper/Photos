//
//  VideoTimeLineView.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/8/24.
//

import UIKit
import AVFoundation
import Combine
import CoreImage

final class VideoTimeLineView: UIView {
    
    // MARK: - ViewProperteis
    private let baseStackView: UIStackView = {
        let view = UIStackView()
        view.backgroundColor = .systemBackground
        view.axis = .horizontal
        view.spacing = 0
        view.alignment = .center
        view.distribution = .fillEqually
        
        return view
    }()
    
    private let timeLinePositionView: UIView = {
        let view = UIView()
        view.backgroundColor = .label
        
        return view
    }()
    
    private let timeLineSlider: UISlider = {
        let slider = UISlider()
        slider.minimumTrackTintColor = .clear
        slider.maximumTrackTintColor = .clear
        slider.thumbTintColor = .clear
        
        return slider
    }()
    
    // MARK: - Properties
    let seekPublisher = PassthroughSubject<CMTime, Never>()
    private var context: CIContext = CIContext()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setSubViews()
        connectTarget()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setSubViews
    private func setSubViews() {
        [baseStackView, timeLinePositionView, 
         timeLineSlider].forEach {
            addSubview($0)
        }
        
        setConstraints()
    }
    
    private func setConstraints() {
        baseStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        timeLinePositionView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.width.equalTo(2)
            $0.leading.equalToSuperview()
        }
        
        timeLineSlider.snp.makeConstraints {
            $0.edges.equalTo(baseStackView)
        }
    }
    
    // MARK: - Method
    private func connectTarget() {
        timeLineSlider.addTarget(self, action: #selector(timeLineSliderAction(_:)), for: .valueChanged)
    }
    
    @objc private func timeLineSliderAction(_ sender: UISlider) {
        seekPublisher.send(CMTime(seconds: Double(self.timeLineSlider.value), preferredTimescale: Int32(NSEC_PER_SEC)))
    }
    
    func setTimeLineView(asset: AVAsset, filter: FilterValue? = nil, completion: @escaping (() -> Void)) {
        VideoEditor().getTimeLineImages(asset: asset, count: 9) { [weak self] images in
            guard let self = self else { return }
            var images = images
            baseStackView.arrangedSubviews.forEach {
                self.baseStackView.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }
            if let filter = filter {
                images = images.compactMap {
                    $0.applyFilter(filter: filter, context: self.context)
                }.map {
                    UIImage(cgImage: $0)
                }
            }
            
            images.forEach {
                let view = UIImageView(image: $0)
                self.baseStackView.addArrangedSubview(view)
            }
            completion()
        }
        let time = Float(CMTimeGetSeconds(AVPlayerItem(asset: asset).duration))
        if time > 0 {
            timeLineSlider.maximumValue = time
        }
    }
    
    func setTimeLinePosition(currentTime: Double, totalTime: CMTime) {
        let totalTimeSecondsFloat = totalTime.seconds
        let offset = CGFloat(currentTime / totalTimeSecondsFloat)
        let playPosition = (baseStackView.bounds.width) * offset
        
        timeLinePositionView.center.x = playPosition
        timeLineSlider.value = Float(currentTime)
    }
    
}

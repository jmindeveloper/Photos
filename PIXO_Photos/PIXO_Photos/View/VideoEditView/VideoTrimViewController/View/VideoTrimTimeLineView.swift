//
//  VideoTrimTimeLineView.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/9/24.
//

import UIKit
import AVFoundation

final class VideoTrimTimeLineView: UIView {
    private let timeLineView: VideoTimeLineView = VideoTimeLineView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setSubViews
    private func setSubViews() {
        [timeLineView].forEach {
            addSubview($0)
        }
        
        setConstraints()
    }
    
    private func setConstraints() {
        timeLineView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // MARK: - Method
    func setTimeLineView(asset: AVAsset) {
        timeLineView.setTimeLineView(asset: asset, completion: { })
    }
    
    func setTimeLinePosition(currentTime: Double, totalTime: CMTime) {
        timeLineView.setTimeLinePosition(currentTime: currentTime, totalTime: totalTime)
    }
}

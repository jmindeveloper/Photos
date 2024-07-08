//
//  VideoTimeLineView.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/8/24.
//

import UIKit
import AVFoundation

final class VideoTimeLineView: UIView {
    
    private let baseStackView: UIStackView = {
        let view = UIStackView()
        view.backgroundColor = .systemBackground
        view.axis = .horizontal
        view.spacing = 0
        view.alignment = .center
        view.distribution = .fillEqually
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setSubViews() {
        [baseStackView].forEach {
            addSubview($0)
        }
        
        setConstraints()
    }
    
    private func setConstraints() {
        baseStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setTimeLineView(asset: AVAsset, completion: @escaping (() -> Void)) {
        VideoEditor().getTimeLineImages(asset: asset, count: 9) { [weak self] images in
            self?.baseStackView.arrangedSubviews.forEach {
                self?.baseStackView.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }
            images.forEach {
                let view = UIImageView(image: $0)
                self?.baseStackView.addArrangedSubview(view)
            }
            completion()
        }
    }
}

//
//  ImageCollectionViewCell.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/8/24.
//

import UIKit
import SDWebImage

final class ImageCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "ImageCollectionViewCell"
    
    // MARK: - ViewProperties
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    // MARK: - Properties
    var tapImageHandler: ((UIImage?) -> Void)?
    var imageViewContentMode: ContentMode = .scaleAspectFill {
        didSet {
            imageView.contentMode = imageViewContentMode
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setSubViews() {
        contentView.addSubview(imageView)
        
        setConstraints()
    }
    
    private func setConstraints() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = UIImage()
        imageView.sd_cancelCurrentImageLoad()
    }
    
    func setImage(url: URL?, contentMode: ContentMode) {
        imageView.sd_setImage(with: url)
        imageView.contentMode = contentMode
    }
    
    func setImage(image: UIImage?, contentMode: ContentMode) {
        imageView.image = image
        imageView.contentMode = contentMode
    }
}


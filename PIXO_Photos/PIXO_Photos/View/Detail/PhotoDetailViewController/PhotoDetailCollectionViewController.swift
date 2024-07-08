//
//  PhotoDetailCollectionViewController.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/8/24.
//

import UIKit
import SnapKit

final class PhotoDetailCollectionViewController: UIViewController {
    
    // MARK: - ViewProperties
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: horizontalSwipeLayout())
        collectionView.backgroundColor = .black
        collectionView.alwaysBounceVertical = false
        
        collectionView.register(
            ImageCollectionViewCell.self,
            forCellWithReuseIdentifier: ImageCollectionViewCell.identifier
        )
        collectionView.register(
            VideoCollectionViewCell.self,
            forCellWithReuseIdentifier: VideoCollectionViewCell.identifier
        )
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - setSubViews
    private func setSubViews() {
        view.backgroundColor = .black
        view.addSubview(collectionView)
        
        setConstraints()
    }
    
    private func setConstraints() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // MARK: - CollectionViewLayout
    private func horizontalSwipeLayout() -> UICollectionViewCompositionalLayout {
        let viewFrame = UIScreen.main.bounds
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(viewFrame.width), heightDimension: .absolute(viewFrame.height))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(viewFrame.width), heightDimension: .absolute(viewFrame.height))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
                
        return UICollectionViewCompositionalLayout(section: section)
    }
}

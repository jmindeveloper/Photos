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
//        collectionView.isScrollEnabled = false
        
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
    
    // MARK: - Properties
    private lazy var currentShowCellIndex: Int = 0 {
        didSet {
            print("currentIndex", currentShowCellIndex)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSubViews()
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
        let width = Constant.SCREEN_WIDTH - Constant.SAFEAREA_INSETS.left - Constant.SAFEAREA_INSETS.right
        let height = Constant.SCREEN_HEIGHT - Constant.SAFEAREA_INSETS.top - Constant.SAFEAREA_INSETS.bottom
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(width), heightDimension: .absolute(height))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(width), heightDimension: .absolute(height))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
                
        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, _, _ in
            guard let self = self else { return }
            currentShowCellIndex = visibleItems.last?.indexPath.item ?? 0
        }
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

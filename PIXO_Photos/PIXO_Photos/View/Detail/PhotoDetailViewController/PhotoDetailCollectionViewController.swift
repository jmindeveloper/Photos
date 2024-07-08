//
//  PhotoDetailCollectionViewController.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/8/24.
//

import UIKit
import SnapKit
import SDWebImage

final class PhotoDetailCollectionViewController: UIViewController {
    
    // MARK: - ViewProperties
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: horizontalSwipeLayout())
        collectionView.backgroundColor = .systemBackground
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
    
    lazy var thumbnailCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: thumbnailLayout())
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = false
        collectionView.alwaysBounceHorizontal = false
        
        collectionView.register(
            ImageCollectionViewCell.self,
            forCellWithReuseIdentifier: ImageCollectionViewCell.identifier
        )
        
        return collectionView
    }()
    
    private let selectImageBoxView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.label.cgColor
        view.layer.borderWidth = 2
        
        return view
    }()
    
    // MARK: - Properties
    lazy var currentShowCellIndex: Int = 0 {
        didSet {
            print("currentIndex", currentShowCellIndex)
            thumbnailCollectionView.scrollToItem(
                at: IndexPath(item: currentShowCellIndex, section: 0),
                at: .left,
                animated: false
            )
            collectionView.scrollToItem(
                at: IndexPath(item: currentShowCellIndex, section: 0),
                at: .centeredHorizontally,
                animated: false
            )
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
        view.addSubview(thumbnailCollectionView)
        view.addSubview(selectImageBoxView)
        
        setConstraints()
    }
    
    private func setConstraints() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        thumbnailCollectionView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(Constant.SCREEN_WIDTH / 9)
        }
        
        selectImageBoxView.snp.makeConstraints {
            $0.centerY.verticalEdges.equalTo(thumbnailCollectionView)
            $0.width.equalTo(Constant.SCREEN_WIDTH / 9)
            $0.leading.equalToSuperview()
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
        section.orthogonalScrollingBehavior = .groupPagingCentered
        
        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, _, _ in
            guard let self = self else { return }
//            currentShowCellIndex = visibleItems.last?.indexPath.item ?? 0
        }
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func thumbnailLayout() -> UICollectionViewCompositionalLayout {
        let size: CGFloat = Constant.SCREEN_WIDTH / 9
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(size), heightDimension: .absolute(size))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(size), heightDimension: .absolute(size))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        let inset = Constant.SCREEN_WIDTH - (Constant.SCREEN_WIDTH / 9 / 2)
        
        section.contentInsets = .init(top: .zero, leading: .zero, bottom: .zero, trailing: inset)
        
        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, _, _ in
            guard let self = self else { return }
//            currentShowCellIndex = visibleItems.last?.indexPath.item ?? 0
        }
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

//
//  PhotoDetailCollectionViewController.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/8/24.
//

import UIKit
import Combine
import SnapKit
import SDWebImage
import AVFoundation

final class PhotoDetailCollectionViewController: UIViewController {
    
    // MARK: - ViewProperties
    lazy var detailCollectionView: UICollectionView = {
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
    
    let selectImageBoxView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.label.cgColor
        view.layer.borderWidth = 2
        
        return view
    }()
    
    let videoTimeLineView = VideoTimeLineView()
    
    // MARK: - Properties
    private var viewModel: PhotoDetailViewModel?
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSubViews()
        binding()
    }
    
    // MARK: - setSubViews
    private func setSubViews() {
        view.backgroundColor = .black
        view.addSubview(detailCollectionView)
        view.addSubview(thumbnailCollectionView)
        view.addSubview(selectImageBoxView)
        view.addSubview(videoTimeLineView)
        videoTimeLineView.isHidden = true
        
        setConstraints()
    }
    
    private func setConstraints() {
        detailCollectionView.snp.makeConstraints {
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
        
        videoTimeLineView.snp.makeConstraints {
            $0.edges.equalTo(thumbnailCollectionView)
        }
    }
    
    // MARK: - Method
    private func binding() {
        viewModel?.detailScrollToItemPublisher
            .sink { [weak self] index in
                guard let self = self else { return }
                detailCollectionView.scrollToItem(
                    at: IndexPath(item: index, section: 0),
                    at: .centeredHorizontally,
                    animated: false
                )
            }.store(in: &subscriptions)
        
        viewModel?.thumbnailScrollToItemPublisher
            .sink { [weak self] index in
                guard let self = self else { return }
                thumbnailCollectionView.scrollToItem(
                    at: IndexPath(item: index, section: 0),
                    at: .left,
                    animated: false
                )
            }.store(in: &subscriptions)
        
        videoTimeLineView.seekPublisher
            .sink { [weak self] time in
                guard let self = self else {
                    return
                }
                if let cell = detailCollectionView.cellForItem(at: IndexPath(item: viewModel?.currentItemIndex ?? 0, section: 0)) as? VideoCollectionViewCell {
                    cell.player?.seek(to: time, completionHandler: { _ in })
                }
            }.store(in: &subscriptions)
    }
    
    func setThumbnailViewOpacity(_ isHidden: Bool) {
        thumbnailCollectionView.alpha = isHidden ? 0 : 1
        selectImageBoxView.alpha = isHidden ? 0 : 1
        videoTimeLineView.alpha = isHidden ? 0 : 1
    }
    
    func setViewModel(viewModel: PhotoDetailViewModel) {
        self.viewModel = viewModel
    }
    
    func observeVideoCellVideo() {
        if viewModel?.currentAsset.mediaType != .video {
            return
        }
        if let cell = detailCollectionView.cellForItem(at: IndexPath(item: viewModel?.currentItemIndex ?? 0, section: 0)) as? VideoCollectionViewCell {
            let interval = CMTimeMake(value: 1, timescale: 60)
            let _ = cell.player?.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { [weak self] time in
                self?.videoTimeLineView.setTimeLinePosition(currentTime: cell.player?.currentItem?.currentTime().seconds ?? 0, totalTime: cell.player?.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
            })
            
            NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: cell.player?.currentItem)
                .sink { [weak self] _ in
                    self?.viewModel?.isPlayVideo = false
                }.store(in: &subscriptions)
        }
    }
    
    // MARK: - CollectionViewLayout
    private func horizontalSwipeLayout() -> UICollectionViewCompositionalLayout {
        let width = Constant.SCREEN_WIDTH - Constant.SAFEAREA_INSETS.left - Constant.SAFEAREA_INSETS.right
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(width), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(width), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        
        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, offset, _ in
            guard let self = self else { return }
            // 이미지 넘기는 도중에는 작동하지 않도록
            var visibleItems = visibleItems
            visibleItems.removeAll { $0.frame.minX < offset.x - $0.frame.width }
            if visibleItems.count == 1 {
                viewModel?.detailCollectionViewShowCellIndex = visibleItems.last?.indexPath.item ?? 0
            }
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
        
        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, offset, _ in
            guard let self = self else { return }
            // MARK: - visibleItem Error
            // visibleItem에 0..<item.count 만큼의 range가 포함돼서 나옴
            // scrollOffset이랑 비교해서 작은값들은 remove
            var visibleItems = visibleItems
            visibleItems.removeAll { $0.frame.minX < offset.x }
            
            viewModel?.thumbnailCollectionViewShowCellIndex = visibleItems.first?.indexPath.item ?? 0
        }
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

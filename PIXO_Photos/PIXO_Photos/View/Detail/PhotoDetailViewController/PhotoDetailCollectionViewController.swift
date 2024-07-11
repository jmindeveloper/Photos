//
//  PhotoDetailCollectionViewController.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/8/24.
//

import UIKit
import Combine
import SnapKit
import AVFoundation

final class PhotoDetailCollectionViewController: UIViewController {
    
    // MARK: - View Properties
    lazy var mainCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: mainLayout())
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
    
    lazy var previewCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: previewLayout())
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = false
        collectionView.alwaysBounceHorizontal = false
        
        collectionView.register(
            ImageCollectionViewCell.self,
            forCellWithReuseIdentifier: ImageCollectionViewCell.identifier
        )
        
        return collectionView
    }()
    
    let currentImageBoxView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.label.cgColor
        view.layer.borderWidth = 2
        
        return view
    }()
    
    let videoTimeLineView = VideoTimeLineView()
    
    // MARK: - Properties
    private var viewModel: (any PhotoDetailViewModelProtocol)?
    private var subscriptions = Set<AnyCancellable>()
    private let cellColumnCount: CGFloat = 9
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        binding()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopCurrentVideo()
    }
    
    // MARK: - setSubViews
    private func setupSubviews() {
        view.backgroundColor = .black
        view.addSubview(mainCollectionView)
        view.addSubview(previewCollectionView)
        view.addSubview(currentImageBoxView)
        view.addSubview(videoTimeLineView)
        videoTimeLineView.isHidden = true
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        mainCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        previewCollectionView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(Constant.SCREEN_WIDTH / cellColumnCount)
        }
        
        currentImageBoxView.snp.makeConstraints {
            $0.centerY.verticalEdges.equalTo(previewCollectionView)
            $0.width.equalTo(Constant.SCREEN_WIDTH / cellColumnCount)
            $0.leading.equalToSuperview()
        }
        
        videoTimeLineView.snp.makeConstraints {
            $0.edges.equalTo(previewCollectionView)
        }
    }
    
    // MARK: - Methods
    private func binding() {
        viewModel?.mainScrollToItemPublisher
            .sink { [weak self] index in
                self?.scrollToItem(in: self?.mainCollectionView, at: index, position: .centeredHorizontally)
            }.store(in: &subscriptions)
        
        viewModel?.previewScrollToItemPublisher
            .sink { [weak self] index in
                self?.scrollToItem(in: self?.previewCollectionView, at: index, position: .left)
            }.store(in: &subscriptions)
        
        videoTimeLineView.seekPublisher
            .sink { [weak self] time in
                self?.seekVideo(to: time)
            }.store(in: &subscriptions)
    }
    
    private func scrollToItem(in collectionView: UICollectionView?, at index: Int, position: UICollectionView.ScrollPosition) {
        collectionView?.scrollToItem(at: IndexPath(item: index, section: 0), at: position, animated: false)
    }
    
    private func seekVideo(to time: CMTime) {
        videoCellAction { cell in
            cell.player?.seek(to: time, completionHandler: { _ in })
        }
    }
    
    private func stopCurrentVideo() {
        videoCellAction { cell in
            cell.stopVideo()
        }
    }
    
    func setThumbnailViewOpacity(_ isHidden: Bool) {
        let alpha: CGFloat = isHidden ? 0 : 1
        previewCollectionView.alpha = alpha
        currentImageBoxView.alpha = alpha
        videoTimeLineView.alpha = alpha
    }
    
    func setViewModel(viewModel: any PhotoDetailViewModelProtocol) {
        self.viewModel = viewModel
    }
    
    func observeVideoCellVideo() {
        guard viewModel?.currentAsset.mediaType == .video else { return }
        videoCellAction { [weak self] cell in
            guard let self = self else { return }
            let interval = CMTimeMake(value: 1, timescale: 60)
            cell.player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
                self?.videoTimeLineView.setTimeLinePosition(
                    currentTime: time.seconds,
                    totalTime: cell.player?.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1)
                )
            }
            NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: cell.player?.currentItem)
                .sink { [weak self] _ in
                    guard let self = self else { return }
                    viewModel?.isPlayVideo = false
                }.store(in: &subscriptions)
        }
    }
    
    private func videoCellAction(action: @escaping (VideoCollectionViewCell) -> Void) {
        if let cell = mainCollectionView.cellForItem(at: IndexPath(item: viewModel?.currentItemIndex ?? 0, section: 0)) as? VideoCollectionViewCell {
            action(cell)
        }
    }
    
    // MARK: - CollectionView Layouts
    private func mainLayout() -> UICollectionViewCompositionalLayout {
        let width = Constant.SCREEN_WIDTH - Constant.SAFEAREA_INSETS.left - Constant.SAFEAREA_INSETS.right
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(width), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(width), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        
        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, offset, _ in
            guard let self = self else { return }
            var visibleItems = visibleItems
            visibleItems.removeAll { $0.frame.minX < offset.x - $0.frame.width }
            // 이미지 넘기는 도중에는 작동하지 않도록
            if visibleItems.count == 1 {
                viewModel?.mainCollectionViewShowCellIndex = visibleItems.last?.indexPath.item ?? 0
            }
        }
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func previewLayout() -> UICollectionViewCompositionalLayout {
        let size: CGFloat = Constant.SCREEN_WIDTH / cellColumnCount
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(size), heightDimension: .absolute(size))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(size), heightDimension: .absolute(size))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        let inset = Constant.SCREEN_WIDTH - (Constant.SCREEN_WIDTH / cellColumnCount / 2)
        
        section.contentInsets = .init(top: .zero, leading: .zero, bottom: .zero, trailing: inset)
        
        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, offset, _ in
            guard let self = self else { return }
            // MARK: - visibleItem Error
            // visibleItem에 0..<item.count 만큼의 range가 포함돼서 나옴
            // scrollOffset이랑 비교해서 작은값들은 remove
            var visibleItems = visibleItems
            visibleItems.removeAll { $0.frame.minX < offset.x }
            if visibleItems.isEmpty {
                viewModel?.previewCollectionViewShowCellIndex = (viewModel?.assets.count ?? 1) - 1
                return
            }
            viewModel?.previewCollectionViewShowCellIndex = visibleItems.first?.indexPath.item ?? 0
        }
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}


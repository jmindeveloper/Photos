//
//  PhotoDetailViewControllerRepresentableView.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/8/24.
//

import SwiftUI
import Photos
import UIKit

struct PhotoDetailViewControllerRepresentableView<VM: PhotoDetailViewModelProtocol>: UIViewControllerRepresentable {
    @EnvironmentObject var viewModel: PhotoDetailViewModel
    let viewController = PhotoDetailCollectionViewController()
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> PhotoDetailCollectionViewController {
        viewController.detailCollectionView.dataSource = context.coordinator
        viewController.detailCollectionView.delegate = context.coordinator
        viewController.thumbnailCollectionView.dataSource = context.coordinator
        
        viewController.setViewModel(viewModel: viewModel)
        context.coordinator.viewController = viewController
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: PhotoDetailCollectionViewController, context: Context) {
        if viewModel.isAssetsChange {
            context.coordinator.assets = viewModel.assets
            uiViewController.detailCollectionView.reloadData()
            uiViewController.thumbnailCollectionView.reloadData()
            viewModel.isAssetsChange = false
        }
        
        UIView.animate(withDuration: 0.2) {
            uiViewController.setThumbnailViewOpacity(viewModel.hiddenToolBar)
        }
        
        if viewModel.currentAsset.mediaType == .video {
            startVideo(in: uiViewController)
            viewModel.isPlayVideo ? playVideo(in: uiViewController) : pauseVideo(in: uiViewController)
        }
    }
    
    private func startVideo(in vc: PhotoDetailCollectionViewController) {
        guard viewModel.currentAsset.mediaType == .video,
              let cell = vc.detailCollectionView.cellForItem(at: IndexPath(item: viewModel.currentItemIndex, section: 0)) as? VideoCollectionViewCell,
              let videoAsset = cell.videoAsset else { return }
        
        if cell.isStartVideo {
            return
        }
        let filter = VideoFilterStorage.getFilter(id: viewModel.currentAsset.localIdentifier)
        
        vc.videoTimeLineView.setTimeLineView(asset: videoAsset, filter: filter) {
            vc.videoTimeLineView.isHidden = false
            vc.thumbnailCollectionView.isHidden = true
            vc.currentImageBoxView.isHidden = true
        }
        
        cell.startVideo()
    }
    
    private func playVideo(in vc: PhotoDetailCollectionViewController) {
        guard viewModel.currentAsset.mediaType == .video,
              let cell = vc.detailCollectionView.cellForItem(at: IndexPath(item: viewModel.currentItemIndex, section: 0)) as? VideoCollectionViewCell else { return }
        
        vc.observeVideoCellVideo()
        cell.playVideo()
    }
    
    private func pauseVideo(in vc: PhotoDetailCollectionViewController) {
        guard viewModel.currentAsset.mediaType == .video,
              let cell = vc.detailCollectionView.cellForItem(at: IndexPath(item: viewModel.currentItemIndex, section: 0)) as? VideoCollectionViewCell else { return }
        
        cell.pauseVideo()
    }
    
    class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
        var assets: [PHAsset] = []
        var parent: PhotoDetailViewControllerRepresentableView
        weak var viewController: PhotoDetailCollectionViewController?
        
        init(_ parent: PhotoDetailViewControllerRepresentableView) {
            self.parent = parent
            self.assets = parent.viewModel.assets
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return assets.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let asset = assets[indexPath.item]
            if collectionView === parent.viewController.detailCollectionView {
                return configureDetailCell(for: collectionView, at: indexPath, with: asset)
            } else {
                return configureThumbnailCell(for: collectionView, at: indexPath, with: asset)
            }
        }
        
        private func configureDetailCell(for collectionView: UICollectionView, at indexPath: IndexPath, with asset: PHAsset) -> UICollectionViewCell {
            switch asset.mediaType {
            case .image:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as? ImageCollectionViewCell else {
                    return UICollectionViewCell()
                }
                PhotoLibrary.requestImageURL(with: asset) { url in
                    cell.setImage(url: url, contentMode: .scaleAspectFit)
                }
                return cell
                
            case .video:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionViewCell.identifier, for: indexPath) as? VideoCollectionViewCell else {
                    return UICollectionViewCell()
                }
                PhotoLibrary.requestImage(with: asset) { image, _ in
                    cell.setImage(image: image)
                }
                PhotoLibrary.getVideoAsset(with: asset) { asset in
                    cell.setVideoAsset(asset: asset)
                }
                cell.assetId = asset.localIdentifier
                return cell
                
            default:
                return UICollectionViewCell()
            }
        }
        
        private func configureThumbnailCell(for collectionView: UICollectionView, at indexPath: IndexPath, with asset: PHAsset) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as? ImageCollectionViewCell else {
                return UICollectionViewCell()
            }
            PhotoLibrary.requestImage(with: asset) { image, _ in
                cell.setImage(image: image, contentMode: .scaleAspectFill)
            }
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            if let cell = cell as? VideoCollectionViewCell {
                cell.stopVideo()
            }
            viewController?.videoTimeLineView.isHidden = true
            viewController?.currentImageBoxView.isHidden = false
            viewController?.thumbnailCollectionView.isHidden = false
        }
    }
}

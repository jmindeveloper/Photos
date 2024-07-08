//
//  PhotoDetailViewControllerRepresentableView.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/8/24.
//

import SwiftUI
import Photos
import UIKit

struct PhotoDetailViewControllerRepresentableView: UIViewControllerRepresentable {
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
        if viewModel.isAssetsCahnge {
            context.coordinator.assets = viewModel.assets
            uiViewController.detailCollectionView.reloadData()
            uiViewController.thumbnailCollectionView.reloadData()
            viewModel.isAssetsCahnge = false
        }
        
        UIView.animate(withDuration: 0.2) {
            uiViewController.setThumbnailViewOpacity(viewModel.hiddenToolBar)
        }
        
        if viewModel.currentAsset.mediaType == .video {
            startVideo(vc: uiViewController)
            if viewModel.isPlayVideo {
                playVideo(vc: uiViewController)
            } else {
                pauseVideo(vc: uiViewController)
            }
        }
    }
    
    func startVideo(vc: PhotoDetailCollectionViewController) {
        if viewModel.currentAsset.mediaType != .video {
            return
        }
        guard let cell = vc.detailCollectionView.cellForItem(
            at: IndexPath(item: viewModel.currentItemIndex, section: 0)
        ) as? VideoCollectionViewCell else {
            return
        }
        
        if let asset = cell.videoAsset {
            vc.videoTimeLineView.setTimeLineView(asset: asset) {
                vc.videoTimeLineView.isHidden = false
                vc.thumbnailCollectionView.isHidden = true
                vc.selectImageBoxView.isHidden = true
            }
        }
        
        cell.startVideo()
    }
    
    func playVideo(vc: PhotoDetailCollectionViewController) {
        if viewModel.currentAsset.mediaType != .video {
            return
        }
        guard let cell = vc.detailCollectionView.cellForItem(
            at: IndexPath(item: viewModel.currentItemIndex, section: 0)
        ) as? VideoCollectionViewCell else {
            return
        }
        
        vc.observeVideoCellVideo()
        cell.playVideo()
    }
    
    func pauseVideo(vc: PhotoDetailCollectionViewController) {
        if viewModel.currentAsset.mediaType != .video {
            return
        }
        guard let cell = vc.detailCollectionView.cellForItem(
            at: IndexPath(item: viewModel.currentItemIndex, section: 0)
        ) as? VideoCollectionViewCell else {
            return
        }
        
        cell.pauseVideo()
    }
    
    class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
        var assets: [PHAsset] = []
        var parent: PhotoDetailViewControllerRepresentableView
        var viewController: PhotoDetailCollectionViewController?
        
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
                switch asset.mediaType {
                case .image:
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: ImageCollectionViewCell.identifier,
                        for: indexPath
                    ) as? ImageCollectionViewCell else {
                        return UICollectionViewCell()
                    }
                    
                    PhotoLibrary.requestImageURL(with: asset) { url in
                        cell.setImage(url: url, contentMode: .scaleAspectFit)
                    }
                    
                    return cell
                case .video:
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: VideoCollectionViewCell.identifier,
                        for: indexPath
                    ) as? VideoCollectionViewCell else {
                        return UICollectionViewCell()
                    }
                    
                    PhotoLibrary.requestImage(with: asset) { image, _ in
                        cell.setImage(image: image)
                    }
                    
                    PhotoLibrary.getVideoAsset(with: asset) { asset in
                        cell.setVideoAsset(asset: asset)
                    }
                    
                    return cell
                default:
                    return UICollectionViewCell()
                }
            } else {
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ImageCollectionViewCell.identifier,
                    for: indexPath
                ) as? ImageCollectionViewCell else {
                    return UICollectionViewCell()
                }
                
                PhotoLibrary.requestImage(with: asset) { image, _ in
                    cell.setImage(image: image, contentMode: .scaleAspectFill)
                }
                
                return cell
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            let cell = cell as? VideoCollectionViewCell
            cell?.stopVideo()
            viewController?.videoTimeLineView.isHidden = true
            viewController?.selectImageBoxView.isHidden = false
            viewController?.thumbnailCollectionView.isHidden = false
        }
    }
}

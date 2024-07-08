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
        viewController.thumbnailCollectionView.dataSource = context.coordinator
        viewController.setViewModel(viewModel: viewModel)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            viewController.currentShowCellIndex = viewModel.currentItemIndex
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: PhotoDetailCollectionViewController, context: Context) {
        context.coordinator.assets = viewModel.assets
        uiViewController.detailCollectionView.reloadData()
    }
    
    class Coordinator: NSObject, UICollectionViewDataSource {
        var assets: [PHAsset] = []
        var parent: PhotoDetailViewControllerRepresentableView
        
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
    }
}

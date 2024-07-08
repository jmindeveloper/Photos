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
    @State var assets: [PHAsset] = []
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> PhotoDetailCollectionViewController {
        let vc = PhotoDetailCollectionViewController()
        vc.collectionView.dataSource = context.coordinator
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: PhotoDetailCollectionViewController, context: Context) {
        context.coordinator.assets = assets
        uiViewController.collectionView.reloadData()
    }
    
    class Coordinator: NSObject, UICollectionViewDataSource {
        var assets: [PHAsset] = []
        var parent: PhotoDetailViewControllerRepresentableView
        
        init(_ parent: PhotoDetailViewControllerRepresentableView) {
            self.parent = parent
            self.assets = parent.assets
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return assets.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let asset = assets[indexPath.item]
            switch asset.mediaType {
            case .image:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ImageCollectionViewCell.identifier,
                    for: indexPath
                ) as? ImageCollectionViewCell else {
                    return UICollectionViewCell()
                }
                
                PhotoLibrary.requestImageURL(with: asset) { url in
                    cell.setImage(url: url)
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
        }
    }
}

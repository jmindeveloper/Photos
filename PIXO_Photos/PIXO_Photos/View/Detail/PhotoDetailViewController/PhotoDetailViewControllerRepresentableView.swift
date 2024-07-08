//
//  PhotoDetailViewControllerRepresentableView.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/8/24.
//

import SwiftUI
import UIKit

struct PhotoDetailViewControllerRepresentableView: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> PhotoDetailCollectionViewController {
        return PhotoDetailCollectionViewController()
    }
    
    func updateUIViewController(_ uiViewController: PhotoDetailCollectionViewController, context: Context) {
        uiViewController.collectionView.reloadData()
    }
    
    class Coordinator: NSObject, UICollectionViewDataSource {
        var parent: PhotoDetailViewControllerRepresentableView
        
        init(_ parent: PhotoDetailViewControllerRepresentableView) {
            self.parent = parent
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return 10
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            return UICollectionViewCell()
        }
    }
}

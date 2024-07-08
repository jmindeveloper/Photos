//
//  PhotoDetailViewModel.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/8/24.
//

import Foundation
import Combine
import UIKit
import Photos

final class PhotoDetailViewModel: ObservableObject {
    @Published var assets: [PHAsset] = [] {
        didSet {
            isAssetsCahnge = true
        }
    }
    var currentItemIndex: Int {
        didSet {
            self.currentAsset = assets[currentItemIndex]
        }
    }
    @Published var currentAsset: PHAsset
    var isAssetsCahnge: Bool = false
    private var library: PhotoLibrary
    
    @Published var hiddenToolBar: Bool = false
    
    @Published var detailCollectionViewShowCellIndex: Int = 0 {
        didSet {
            detailScrollToItemBlock = true
            thumbnailScrollToItemBlock = false
        }
    }
    @Published var thumbnailCollectionViewShowCellIndex: Int = 0  {
        didSet {
            detailScrollToItemBlock = false
            thumbnailScrollToItemBlock = true
        }
    }
    
    private var subscriptions = Set<AnyCancellable>()
    
    var detailScrollToItemBlock: Bool = false
    var thumbnailScrollToItemBlock: Bool = false
    
    let detailScrollToItemPublisher = PassthroughSubject<Int, Never>()
    let thumbnailScrollToItemPublisher = PassthroughSubject<Int, Never>()
    
    init(assets: [PHAsset], library: PhotoLibrary, currentItemIndex: Int) {
        self.assets = assets
        self.library = library
        self.currentAsset = assets[currentItemIndex]
        self.currentItemIndex = currentItemIndex
        binding()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.detailScrollToItemPublisher.send(currentItemIndex)
            self?.thumbnailScrollToItemPublisher.send(currentItemIndex)
        }
    }
    
    // MARK: - Method
    private func binding() {
        $detailCollectionViewShowCellIndex
            .sink { [weak self] index in
                self?.currentItemIndex = index
                if self?.thumbnailScrollToItemBlock == false {
                    self?.thumbnailScrollToItemPublisher.send(index)
                }
            }.store(in: &subscriptions)
        
        $thumbnailCollectionViewShowCellIndex
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] index in
                self?.currentItemIndex = index
                if self?.detailScrollToItemBlock == false {
                    self?.detailScrollToItemPublisher.send(index)
                }
            }.store(in: &subscriptions)
    }
    
    func getCurrentAssetImage(completion: @escaping ([UIImage]) -> Void) {
        library.requestImages(with: [currentAsset]) { images in
            completion(images)
        }
    }
    
    func deleteCurrentAsset() {
        library.deleteAssets(with: [currentAsset]) { [weak self] in
            guard let self = self else { return }
            assets.removeAll { $0 == self.currentAsset }
        }
    }
    
    func setFavoriteCurrentAsset() {
        library.favoriteAssets(with: [currentAsset]) { [weak self] in
            
        }
    }
}

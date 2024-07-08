//
//  PhotoDetailViewModel.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/8/24.
//

import Foundation
import Combine
import Photos

final class PhotoDetailViewModel: ObservableObject {
    @Published var assets: [PHAsset] = [] {
        didSet {
            isAssetsCahnge = true
        }
    }
    var currentItemIndex: Int {
        didSet {
            collectionViewScrollToItemPublisher.send(currentItemIndex)
        }
    }
    var isAssetsCahnge: Bool = false
    
    @Published var detailCollectionViewShowCellIndex: Int = 0
    @Published var thumbnailCollectionViewShowCellIndex: Int = 0
    private var subscriptions = Set<AnyCancellable>()
    
    let collectionViewScrollToItemPublisher = PassthroughSubject<Int, Never>()
    
    init(assets: [PHAsset], currentItemIndex: Int) {
        self.assets = assets
        self.currentItemIndex = currentItemIndex
        binding()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.collectionViewScrollToItemPublisher.send(currentItemIndex)
        }
    }
    
    private func binding() {
        $detailCollectionViewShowCellIndex
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] index in
                print(index)
                self?.currentItemIndex = index
            }.store(in: &subscriptions)
        
        $thumbnailCollectionViewShowCellIndex
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] index in
                print(index)
                self?.currentItemIndex = index
            }.store(in: &subscriptions)
    }
}

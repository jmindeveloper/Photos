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
    var currentItemIndex: Int
    var isAssetsCahnge: Bool = false
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
    
    init(assets: [PHAsset], currentItemIndex: Int) {
        self.assets = assets
        self.currentItemIndex = currentItemIndex
        binding()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.detailScrollToItemPublisher.send(currentItemIndex)
            self?.thumbnailScrollToItemPublisher.send(currentItemIndex)
        }
    }
    
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
}

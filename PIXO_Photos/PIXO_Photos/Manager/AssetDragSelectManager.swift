//
//  AssetDragSelectManager.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/7/24.
//

import UIKit
import Photos

class AssetDragSelectManager {
    @Published var selectedAssets: Set<PHAsset> = []
    
    private var dragStartIndex: Int? = nil
    private var isDragStart: Bool = false
    private var isInsert: Bool = false
    private var beforeSelectedAssets: Set<PHAsset> = []
    var assetWithFrame: [(asset: PHAsset, frame: CGRect)] = []
    
    func setAssetFrame(index: Int, rect: CGRect) {
        assetWithFrame[index].frame = rect
    }
    
    func dragingAssetSelect(startLocation: CGPoint, currentLocation: CGPoint) {
        guard let startIndex = itemIndexFromPoint(startLocation),
              let endIndex = itemIndexFromPoint(currentLocation) else {
            return
        }
        if dragStartIndex == nil {
            dragStartIndex = startIndex
        }
        
        if beforeSelectedAssets.isEmpty {
            beforeSelectedAssets = selectedAssets
        }
        
        let (min, max) = endIndex >= dragStartIndex! ? (dragStartIndex!, endIndex) : (endIndex, dragStartIndex!)
        
        if !isDragStart {
            if !selectedAssets.contains(assetWithFrame[startIndex].asset) {
                isInsert = true
            }
            isDragStart = true
        }
        
        selectedAssets = beforeSelectedAssets
        
        for i in min..<max + 1 {
            let asset = assetWithFrame[i].asset
            
            if isInsert {
                selectedAssets.insert(asset)
            } else {
                selectedAssets.remove(asset)
            }
        }
    }
    
    func finishDragingAssetSelect() {
        dragStartIndex = nil
        isDragStart = false
        isInsert = false
        beforeSelectedAssets.removeAll()
    }
    
    private func itemIndexFromPoint(_ point: CGPoint) -> Int? {
        if point.x < 0 || point.y < 0 {
            return nil
        }
        for i in 0..<assetWithFrame.count {
            let frame = assetWithFrame[i].frame
            // outside of scrollview
            if (frame.minY < 0 && frame.maxY < 0) || (frame.minX < 0 && frame.maxX < 0) {
                continue
            }
            if frame.contains(point) {
                return i
            }
        }
        return nil
    }
}

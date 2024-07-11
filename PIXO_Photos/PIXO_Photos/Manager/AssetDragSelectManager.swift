//
//  AssetDragSelectManager.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/7/24.
//

import UIKit
import Photos

class AssetDragSelectManager: NSObject {
    @Published var selectedAssets: Set<PHAsset> = []
    
    private var dragStartIndex: Int? = nil
    private var isInsert: Bool = false
    private var beforeSelectedAssets: Set<PHAsset> = []
    var assetWithFrame: [(asset: PHAsset, frame: CGRect)] = []
    
    func setAssetFrame(index: Int, rect: CGRect) {
        if index >= assetWithFrame.count { return }
        assetWithFrame[index].frame = rect
    }
    
    func draggingAssetSelect(startLocation: CGPoint, currentLocation: CGPoint) {
        // 드래그 시작점의 asset index, 현재 드래그중인 위치의 asset index 계산
        guard let startIndex = itemIndexFromPoint(startLocation),
              let endIndex = itemIndexFromPoint(currentLocation) else {
            return
        }
        // dratStartIndex 저장
        if dragStartIndex == nil {
            dragStartIndex = startIndex
            // startIndex의 asset이 selectedAsset에 포함이 안돼있으면 insert mode
            if !selectedAssets.contains(assetWithFrame[startIndex].asset) {
                isInsert = true
            }
            // 드래그 시작 이전에 저장돼있던 selectedAssets 기억
            beforeSelectedAssets = selectedAssets
        }
        
        let (min, max) = endIndex >= dragStartIndex! ? (dragStartIndex!, endIndex) : (endIndex, dragStartIndex!)
        
        // selectedAssets beforeSelectedAssets으로 초기화
        // 만약 기존 0..<9 까지 드래그됐다가 0..<5 까지 드래그했다면 5..<9 까지는 selectedAssets에 없어야 한다
        // 매 드래그마다 min..<max의 asset들 insert, remove가 이루어지기 때문에 beforeSelectedAssets으로 초기화해줘서 기존 상태로 만들어준다
        selectedAssets = beforeSelectedAssets
        
        for i in min..<max + 1 {
            let asset = assetWithFrame[i].asset
            // insert mode일경우 selectedAsset에 추가 아닐경우 remove
            if isInsert {
                selectedAssets.insert(asset)
            } else {
                selectedAssets.remove(asset)
            }
        }
    }
    
    func finishDraggingAssetSelect() {
        dragStartIndex = nil
        isInsert = false
        beforeSelectedAssets.removeAll()
    }
    
    func toggleSelectPhoto(index: Int) {
        let asset = assetWithFrame[index].asset
        if selectedAssets.contains(asset) {
            selectedAssets.remove(asset)
        } else {
            selectedAssets.insert(asset)
        }
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

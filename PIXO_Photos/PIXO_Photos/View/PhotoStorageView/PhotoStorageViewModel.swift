//
//  PhotoStorageViewModel.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/7/24.
//

import Foundation
import Photos

final class PhotoStorageViewModel: PhotoGridViewModelProtocol {
    private let library = PhotoLibrary()
    private var recentsCollection: PHAssetCollection {
        if let collection = library.collections[.smartAlbum]?.first {
            return collection
        } else {
            fatalError("Recents collection을 찾지 못했습니다.")
        }
    }
    
    @Published var assets: [PHAsset] = []
    lazy var assetWithFrame: [(asset: PHAsset, frame: CGRect)] = assets.map { ($0, .zero) }
    @Published var selectedAssets: Set<PHAsset> = []
    @Published var imageCount: Int = 0
    @Published var videoCount: Int = 0
    @Published var dateRangeString: String = ""
    var visibleAssetsDate: [Date] = [] {
        didSet {
            dateRangeString = getDateRange(date1: visibleAssetsDate.min() ?? Date(), date2: visibleAssetsDate.max() ?? Date())
        }
    }
    
    init() {
        assets = library.getAssets(with: recentsCollection).assets
        videoCount = assets.filter { $0.mediaType == .video }.count
        imageCount = assets.count - videoCount
    }
    
    private func getDateRange(date1: Date, date2: Date) -> String {
        let calendar = Calendar.current
        let date1Componets = calendar.dateComponents([.day, .month, .year], from: date1)
        let date2Componets = calendar.dateComponents([.day, .month, .year], from: date2)
        
        
        if date1Componets.year != date2Componets.year {
            // 년이 다를때
            return "\(date1Componets.year ?? 0)년 \(date1Componets.month ?? 0)월 \(date1Componets.day ?? 0)일 ~ \(date2Componets.year ?? 0)년 \(date2Componets.month ?? 0)월 \(date2Componets.day ?? 0)일"
        } else if date1Componets.month != date2Componets.month {
            // 월이 다를때
            return "\(date1Componets.year ?? 0)년 \(date1Componets.month ?? 0)월 \(date1Componets.day ?? 0)일 ~ \(date2Componets.month ?? 0)월 \(date2Componets.day ?? 0)일"
        } else if date1Componets.day != date2Componets.day {
            // 일이 다를때
            return "\(date1Componets.year ?? 0)년 \(date1Componets.month ?? 0)월 \(date1Componets.day ?? 0)일 ~ \(date2Componets.day ?? 0)일"
        } else {
            // 전부 같을때
            return "\(date1Componets.year ?? 0)년 \(date1Componets.month ?? 0)월 \(date1Componets.day ?? 0)일"
        }
    }
    
    var dragStartIndex: Int? = nil
    var isDragStart: Bool = false
    var isInsert: Bool = false
    
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
        
        let (min, max) = endIndex >= dragStartIndex! ? (dragStartIndex!, endIndex) : (endIndex, dragStartIndex!)
        
        if !isDragStart {
            if !selectedAssets.contains(assetWithFrame[startIndex].asset) {
                isInsert = true
            }
            isDragStart = true
        }
        
        for i in min..<max + 1 {
            let asset = assetWithFrame[i].asset
            
            if isInsert {
                selectedAssets.insert(assetWithFrame[i].asset)
            } else {
                selectedAssets.remove(assetWithFrame[i].asset)
            }
        }
        
        print(selectedAssets.count)
    }
    
    func finishDragingAssetSelect() {
        dragStartIndex = nil
        isDragStart = false
        isInsert = false
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

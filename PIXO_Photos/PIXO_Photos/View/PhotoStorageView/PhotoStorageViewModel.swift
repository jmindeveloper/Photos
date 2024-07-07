//
//  PhotoStorageViewModel.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/7/24.
//

import Foundation
import UIKit
import Photos

final class PhotoStorageViewModel: AssetDragSelectManager, PhotoGridViewModelProtocol {
    private let library = PhotoLibrary()
    private var recentsCollection: PHAssetCollection {
        if let collection = library.collections[.smartAlbum]?.first {
            return collection
        } else {
            fatalError("Recents collection을 찾지 못했습니다.")
        }
    }
    
    @Published var assets: [PHAsset] = []
    
    @Published var imageCount: Int = 0
    @Published var videoCount: Int = 0
    @Published var dateRangeString: String = ""
    var visibleAssetsDate: [Date] = [] {
        didSet {
            dateRangeString = getDateRange(date1: visibleAssetsDate.min() ?? Date(), date2: visibleAssetsDate.max() ?? Date())
        }
    }
    
    override init() {
        super.init()
        assets = library.getAssets(with: recentsCollection).assets
        videoCount = assets.filter { $0.mediaType == .video }.count
        imageCount = assets.count - videoCount
        assetWithFrame = assets.map { ($0, .zero) }
    }
    
    func getSelectedAssetsURL(completion: @escaping ([UIImage]) -> Void) {
        PhotoLibrary.requestImages(with: Array(selectedAssets)) { images in
            completion(images)
        }
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
}

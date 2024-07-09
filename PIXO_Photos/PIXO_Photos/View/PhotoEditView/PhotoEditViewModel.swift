//
//  PhotoEditViewModel.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/9/24.
//

import Foundation
import Photos

final class PhotoEditViewModel: ObservableObject {
    enum EditMode: CaseIterable {
        case Adjust
        case filter
        case Crop
        
        var imageName: String {
            switch self {
            case .filter:
                return "camera.filters"
            case .Adjust:
                return "slider.horizontal.3"
            case .Crop:
                return "crop.rotate"
            }
        }
        
        var title: String {
            switch self {
            case .filter:
                return "필터"
            case .Adjust:
                return "조절"
            case .Crop:
                return "자르기"
            }
        }
    }
    
    @Published var editMode: EditMode = .Adjust
    @Published var editAsset: PHAsset
    
    init(editAsset: PHAsset) {
        self.editAsset = editAsset
    }
}

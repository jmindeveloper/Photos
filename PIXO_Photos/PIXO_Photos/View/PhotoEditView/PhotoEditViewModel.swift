//
//  PhotoEditViewModel.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/9/24.
//

import UIKit
import Photos
import Combine

protocol PhotoEditViewModelProtocol: ObservableObject, FilterManagerProtocol {
    var editMode: PhotoEditViewModel.EditMode { get set }
    var editAsset: PHAsset { get set }
    
    func saveImage(image: UIImage, completion: @escaping (() -> Void))
}

final class PhotoEditViewModel: FilterManager, PhotoEditViewModelProtocol {
    enum EditMode: CaseIterable {
        case Adjust
        case Filter
        case Crop
        
        static var allCases: [PhotoEditViewModel.EditMode] {
            return [.Adjust, .Filter]
        }
        
        var imageName: String {
            switch self {
            case .Filter:
                return "camera.filters"
            case .Adjust:
                return "slider.horizontal.3"
            case .Crop:
                return "crop.rotate"
            }
        }
        
        var title: String {
            switch self {
            case .Filter:
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
        super.init()
    }
    
    func saveImage(image: UIImage, completion: @escaping (() -> Void)) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { success, _ in
            if success {
                completion()
            } else {
                fatalError("이미지 저장 실패")
            }
        }
    }
}

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
        case Filter
        case Crop
        
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
    
    enum AdjustEffect: CaseIterable {
        // Exposure (노출)
        case Exposure
        // Saturation (채도)
        case Saturation
        // Hue (색조)
        case Hue
        // Brightness (휘도)
        case Brightness
        // Contrast (대비)
        case Contrast
        // Highlights (하이라이트)
        case Highlights
        // Shadows (그림자)
        case Shadows
        // Temperature (색온도)
        case Temperature
        // Sharpness (선명도)
        case Sharpness
        
        var imageName: String {
            switch self {
            case .Saturation:
                return "s.circle"
            case .Hue:
                return "drop"
            case .Exposure:
                return "plusminus.circle"
            case .Brightness:
                return "swirl.circle.righthalf.filled"
            case .Contrast:
                return "circle.righthalf.filled.inverse"
            case .Highlights:
                return "circle.lefthalf.striped.horizontal.inverse"
            case .Shadows:
                return "circle.lefthalf.filled.righthalf.striped.horizontal.inverse"
            case .Temperature:
                return "thermometer.low"
            case .Sharpness:
                return "righttriangle.fill"
            }
        }
        
        var title: String {
            switch self {
            case .Saturation:
                return "채도"
            case .Hue:
                return "색조"
            case .Exposure:
                return "노출"
            case .Brightness:
                return "휘도"
            case .Contrast:
                return "대비"
            case .Highlights:
                return "하이라이트"
            case .Shadows:
                return "그림자"
            case .Temperature:
                return "색온도"
            case .Sharpness:
                return "선명도"
            }
        }
    }
    
    @Published var editMode: EditMode = .Adjust
    @Published var editAsset: PHAsset
    @Published var currentAdjustEffect: AdjustEffect = .Exposure
    
    init(editAsset: PHAsset) {
        self.editAsset = editAsset
    }
}

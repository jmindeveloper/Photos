//
//  Filter.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/10/24.
//

import Foundation

enum AdjustEffect: String, CaseIterable {
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
    
    var minValue: Float {
        switch self {
        case .Exposure:
            return -3
        case .Saturation:
            return 0
        case .Hue:
            return -Float.pi
        case .Brightness:
            return -1
        case .Contrast:
            return 0.5
        case .Highlights:
            return 0
        case .Shadows:
            return -1
        case .Temperature:
            return 2000
        case .Sharpness:
            return -2
        }
    }
    
    var maxValue: Float {
        switch self {
        case .Exposure:
            return 3
        case .Saturation:
            return 2
        case .Hue:
            return Float.pi
        case .Brightness:
            return 1
        case .Contrast:
            return 1.5
        case .Highlights:
            return 1
        case .Shadows:
            return 1
        case .Temperature:
            return 10000
        case .Sharpness:
            return 2
        }
    }
}

enum Filter: String, CaseIterable {
    case Original, Mono, Tonal, Noir, Fade, Chrome, Process, Transfer, Instant
    
    static func intToValue(_ v: Int) -> Filter {
        switch v {
        case 0:
            return .Original
        case 1:
            return .Mono
        case 2:
            return .Tonal
        case 3:
            return .Noir
        case 4:
            return .Fade
        case 5:
            return .Chrome
        case 6:
            return .Process
        case 7:
            return .Transfer
        case 8:
            return .Instant
        default:
            return .Original
        }
    }
    
    func valueToInt() -> Int {
        switch self {
        case .Original:
            return 0
        case .Mono:
            return 1
        case .Tonal:
            return 2
        case .Noir:
            return 3
        case .Fade:
            return 4
        case .Chrome:
            return 5
        case .Process:
            return 6
        case .Transfer:
            return 7
        case .Instant:
            return 8
        }
    }
}

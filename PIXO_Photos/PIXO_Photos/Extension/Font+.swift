//
//  Font+.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/7/24.
//

import SwiftUI

extension Font {
    
    enum FontSize {
        case heading1, heading2, heading3
        case subHead1, subHead2, subHead3
        case body1, body2, body3
        case caption1, caption2
        
        var size: CGFloat {
            switch self {
            case .heading1:
                return 40
            case .heading2:
                return 36
            case .heading3:
                return 32
            case .subHead1:
                return 28
            case .subHead2:
                return 24
            case .subHead3:
                return 20
            case .body1:
                return 18
            case .body2:
                return 16
            case .body3:
                return 14
            case .caption1:
                return 12
            case .caption2:
                return 10
            }
        }
    }
    
    static func regular(fontSize: FontSize) -> Font {
        return .system(size: fontSize.size, weight: .regular)
    }
    
    static func medium(fontSize: FontSize) -> Font {
        return .system(size: fontSize.size, weight: .medium)
    }
    
    static func semibold(fontSize: FontSize) -> Font {
        return .system(size: fontSize.size, weight: .semibold)
    }
    
    static func bold(fontSize: FontSize) -> Font {
        return .system(size: fontSize.size, weight: .bold)
    }
    
    static func extraBold(fontSize: FontSize) -> Font {
        return .system(size: fontSize.size, weight: .heavy)
    }
}


//
//  Constant.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/7/24.
//

import UIKit

struct Constant {
    static var SCREEN_WIDTH: CGFloat {
        UIScreen.main.bounds.width
    }
    
    static var SCREEN_HEIGHT: CGFloat {
        UIScreen.main.bounds.height
    }
    
    static var SAFEAREA_INSETS: UIEdgeInsets {
        KEY_WINDOW?.safeAreaInsets ?? .zero
    }
    
    static var KEY_WINDOW: UIWindow? = nil
}

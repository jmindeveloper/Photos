//
//  UIView++.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/7/24.
//

import UIKit

extension UIView {
    func allSubviews() -> [UIView] {
        var allSubviews = subviews
        for subview in subviews {
            allSubviews.append(contentsOf: subview.allSubviews())
        }
        return allSubviews
    }
}

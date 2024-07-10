//
//  Int+.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/10/24.
//

import Foundation

extension Int {
    func toMinSec() -> String {
        let min = self / 60
        let sec = self % 60
        return String(format: "%02d:%02d", min, sec)
    }
}

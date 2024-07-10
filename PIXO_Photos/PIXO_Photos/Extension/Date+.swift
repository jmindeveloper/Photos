//
//  Date+.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/10/24.
//

import Foundation

extension Date {
    func toMd() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        
        return formatter.string(from: self)
    }
}

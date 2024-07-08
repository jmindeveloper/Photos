//
//  ContentMode+.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/9/24.
//

import SwiftUI

extension ContentMode {
    mutating func toggle() {
        self = (self == .fit) ? .fill : .fit
    }
}

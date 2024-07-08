//
//  LazyView.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/8/24.
//

import SwiftUI

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}

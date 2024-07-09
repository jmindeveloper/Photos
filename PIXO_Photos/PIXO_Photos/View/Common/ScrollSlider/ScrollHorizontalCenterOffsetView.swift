//
//  ScrollHorizontalCenterOffsetView.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/9/24.
//

import SwiftUI

struct ScrollHorizontalCenterOffsetView<Content: View>: View {
    let onOffsetChange: (CGFloat) -> Void
    let content: () -> Content
    let axes: Axis.Set
    
    @State var viewSize: CGSize = .zero
    
    init(
        _ axes: Axis.Set = .vertical,
        onOffsetChange: @escaping (CGFloat) -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axes = axes
        self.onOffsetChange = onOffsetChange
        self.content = content
    }
    
    var body: some View {
        ScrollView(axes, showsIndicators: false) {
            offsetReader
            content()
                .padding(.top, -8)
        }
        .readSize(onChange: { size in
            viewSize = size
        })
        .coordinateSpace(name: "SCOLLVIEWFRAME")
        .onPreferenceChange(OffsetPreferenceKey.self, perform: onOffsetChange)
    }
    
    var offsetReader: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(
                    key: OffsetPreferenceKey.self,
                    value: calculateOffset(proxy: proxy)
                )
        }
        .frame(height: 0)
    }
    
    func calculateOffset(proxy: GeometryProxy) -> CGFloat {
        let viewWidth = viewSize.width
        let width = proxy.frame(in: .named("SCOLLVIEWFRAME")).width
        let minX = proxy.frame(in: .named("SCOLLVIEWFRAME")).minX
        
        return abs(minX) / (width - viewWidth)
    }
}

private struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}

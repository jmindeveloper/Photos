//
//  ScrollSlider.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/9/24.
//

import SwiftUI

struct ScrollSlider: View {
    @State var initIndex: Int = 0
    @State private var scrollViewSize: CGSize = .zero
    @State var tickCount: Int = 101
    @State var scrollDisabled: Bool = false
    @Binding var updateSlider: Bool
    
    @Binding var min: Float
    @Binding var max: Float
    @Binding var currentValue: Float
    
    var valueChangeAction: ((Float) -> Void)
    
    init(currentValue: Binding<Float>, min: Binding<Float>, max: Binding<Float>, updateSlider: Binding<Bool>, valueChangeAction: @escaping ((Float) -> Void)) {
        self._currentValue = currentValue
        self._min = min
        self._max = max
        self.valueChangeAction = valueChangeAction
        self._updateSlider = updateSlider
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            ScrollViewReader { scrollViewProxy in
                
                ScrollHorizontalOffsetView(.horizontal) { value in
                    let value = calculateValue(min: min, max: max, percent: Float(value))
                    valueChangeAction(value)
                } content: {
                    HStack(spacing: 4) {
                        ForEach(0..<tickCount, id: \.self) { index in
                            if index == tickCount / 2 {
                                Rectangle()
                                    .fill(Color.yellow)
                                    .frame(width: 2, height: 30)
                            } else if index % 5 == 0 {
                                Rectangle()
                                    .fill(Color(uiColor: .label))
                                    .frame(width: 2, height: 30)
                            } else {
                                Rectangle()
                                    .fill(Color(uiColor: .label))
                                    .frame(width: 1, height: 20)
                            }
                        }
                    }
                    .padding(.horizontal, (scrollViewSize.width / 2) - 2)
                }
                .readSize(onChange: { size in
                    scrollViewSize = size
                })
                .scrollDisabled(scrollDisabled)
                .onAppear {
                    scrollDisabled = true
                    calculateinitIndex(min: min, max: max, current: currentValue)
                    scrollViewProxy.scrollTo(initIndex, anchor: .center)
                    scrollDisabled = false
                    updateSlider = false
                }
                .onChange(of: initIndex) { initValue in
                    scrollDisabled = true
                    calculateinitIndex(min: min, max: max, current: currentValue)
                    scrollViewProxy.scrollTo(initIndex, anchor: .center)
                    scrollDisabled = false
                    updateSlider = false
                }
                .onChange(of: min) { _ in
                    scrollDisabled = true
                    calculateinitIndex(min: min, max: max, current: currentValue)
                    scrollViewProxy.scrollTo(initIndex, anchor: .center)
                    scrollDisabled = false
                    updateSlider = false
                }
                .onChange(of: max) { _ in
                    scrollDisabled = true
                    calculateinitIndex(min: min, max: max, current: currentValue)
                    scrollViewProxy.scrollTo(initIndex, anchor: .center)
                    scrollDisabled = false
                    updateSlider = false
                }
                .onChange(of: updateSlider) { _ in
                    if !updateSlider { return }
                    scrollDisabled = true
                    calculateinitIndex(min: min, max: max, current: currentValue)
                    scrollViewProxy.scrollTo(initIndex, anchor: .center)
                    scrollDisabled = false
                    updateSlider = false
                }
            }
            
            // 고정된 빨간색 기준선
            Rectangle()
                .fill(Color.red)
                .frame(width: 4, height: 50)
            
        }
        .frame(height: 60)
    }
    
    func calculateinitIndex(min: Float, max: Float, current: Float) {
        let percentage = ((current - min) / (max - min))
        initIndex = Int(percentage * Float(tickCount))
        if initIndex >= tickCount {
            initIndex = tickCount - 1
        }
    }
    
    func calculateValue(min: Float, max: Float, percent: Float) -> Float {
        let value = min + percent * (max - min)
        return value
    }
}

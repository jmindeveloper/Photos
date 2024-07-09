//
//  ScrollSlider.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/9/24.
//

import SwiftUI

struct ScrollSlider: View {
    @State private var currentIndex: Int = 50
    @State private var scrollViewSize: CGSize = .zero
    @State var tickCount: Int = 101
    
    var body: some View {
        ZStack(alignment: .center) {
            // 스크롤 가능한 라인 뷰
            ScrollViewReader { scrollViewProxy in
                
                ScrollHorizontalCenterOffsetView(.horizontal) { value in
                    print(value)
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
                .onAppear {
                    scrollViewProxy.scrollTo(currentIndex, anchor: .center)
                }
            }
            
            // 고정된 빨간색 기준선
            Rectangle()
                .fill(Color.red)
                .frame(width: 4, height: 50)
            
        }
        .frame(height: 60)
    }
    
    private func updateIndex(from offset: CGFloat) {
        let newIndex = Int((offset / 10).rounded())
        if newIndex >= 0 && newIndex < 41 {
            if currentIndex != newIndex {
                currentIndex = newIndex
                print("Current Index: \(currentIndex)") // 값 출력
            }
        }
    }
}

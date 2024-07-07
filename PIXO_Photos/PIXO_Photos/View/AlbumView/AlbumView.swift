//
//  AlbumView.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/7/24.
//

import SwiftUI

struct AlbumView: View {
    
    @State var rowCount: Int = 2
    @State var spacingWidth: CGFloat = 10
    
    var body: some View {
        NavigationView {
            ScrollView {
                Divider()
                
                myAlbumHeader()
                    .padding(.vertical, 4)
                    .padding(.horizontal, 16)
                
                GeometryReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        let gridItem = Array(
                            repeating: GridItem(.flexible(), spacing: spacingWidth),
                            count: rowCount
                        )
                        
                        LazyHGrid(rows: gridItem, spacing: spacingWidth){
                            ForEach(0..<100, id: \.self) { i in
                                Color.red
                                    .frame(width: proxy.size.width / 2 - 30)
                            }
                        }
                    }
                    .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
                    .contentMargins(.horizontal, 16, for: .scrollContent)
                }
                .frame(height: 400)
                
                Divider()
                    .padding(.top, 4)
                
                HStack {
                    Text("미디어 유형")
                        .font(.bold(fontSize: .subHead2))
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
            }
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle("앨범")
        }
    }
    
    @ViewBuilder
    private func myAlbumHeader() -> some View {
        HStack {
            Text("나의 앨범")
                .font(.bold(fontSize: .subHead2))
            
            Spacer()
            
            Button {
                
            } label: {
                Text("전체보기")
            }
        }
    }
}

//
//  PhotoStorageView.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/7/24.
//

import SwiftUI
import Photos

struct PhotoStorageView: View {
    @ObservedObject var viewModel = PhotoStorageViewModel()
    @State var columnItemCount: Int = 3
    @State var scrollAsset: PHAsset?
    @State var cellContentMode: ContentMode = ContentMode.fill
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollViewReader { proxy in
                ScrollOffsetView { offset in
                } content: {
                    Color.clear
                        .frame(height: 100)
                    
                    PhotoGridView(
                        assets: $viewModel.assets,
                        columnItemCount: $columnItemCount,
                        cellContentMode: $cellContentMode
                    ) { asset in
                        if let date = asset.creationDate {
                            scrollAsset = asset
                            viewModel.visibleAssetsDate.append(date)
                        }
                    } cellOnDisappearAction: { asset in
                        if let date = asset.creationDate {
                            viewModel.visibleAssetsDate.removeAll {
                                $0 == date
                            }
                        }
                    }
                    
                    Text("\(viewModel.imageCount)장의 사진, \(viewModel.videoCount)개의 비디오")
                        .font(.system(size: 17, weight: .semibold))
                        .padding(.vertical, 10)
                }
                .onAppear {
                    scrollAsset = viewModel.assets.last
                    proxy.scrollTo(scrollAsset?.localIdentifier)
                }
                .onChange(of: columnItemCount) { value in
                    proxy.scrollTo(scrollAsset?.localIdentifier, anchor: .top)
                }
            }
            
            navigationBar()
        }
    }
    
    @ViewBuilder
    private func navigationBar() -> some View {
        HStack(alignment: .top) {
            Text(viewModel.dateRangeString)
                .font(.bold(fontSize: .subHead2))
                .foregroundColor(.white)
            Spacer()
            
            Button {
                
            } label: {
                Text("선택")
                    .font(.medium(fontSize: .caption1))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 1000).fill(.gray)
                    )
            }
            .padding(.trailing, 4)
            
            Menu {
                if columnItemCount > 1 {
                    Button {
                        columnItemCount -= 2
                    } label: {
                        Label("확대", systemImage: "plus.magnifyingglass")
                    }
                }
                
                if columnItemCount < 9 {
                    Button {
                        columnItemCount += 2       
                    } label: {
                        Label("축소", systemImage: "minus.magnifyingglass")
                    }
                }
                
                Button {
                    if cellContentMode == .fit {
                        cellContentMode = .fill
                    } else {
                        cellContentMode = .fit
                    }
                } label: {
                    Label(cellContentMode == .fill ? "영상비 격자" : "정방형 사진 격자", systemImage: "aspectratio")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 12, height: 12)
                    .background(
                        RoundedRectangle(cornerRadius: 1000).fill(.gray)
                            .frame(width: 28, height: 28)
                    )
            }
            .frame(width: 28, height: 28)
        }
        .padding(.horizontal, 16)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.6), Color.clear]), startPoint: .top, endPoint: .bottom)
        )
    }
}

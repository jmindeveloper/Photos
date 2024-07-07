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
    @State var selectMode: Bool = false
    @State var isEnableDragToSelect: Bool = false
    @State var scrollViewFrame: CGRect = .zero
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollViewReader { proxy in
                ScrollOffsetView { offset in
                } content: {
                    Color.clear
                        .frame(height: 100)
                    
                    PhotoGridView<PhotoStorageViewModel>(
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
                    .environmentObject(viewModel)
                    
                    if !selectMode {
                        Text("\(viewModel.imageCount)장의 사진, \(viewModel.videoCount)개의 비디오")
                            .font(.system(size: 17, weight: .semibold))
                            .padding(.vertical, 10)
                    }
                }
                .scrollDisabled(isEnableDragToSelect)
                .coordinateSpace(name: "CARDCELLFRAME")
                .overlay {
                    GeometryReader { geometry -> Color in
                        let frame = geometry.frame(in: .global)
                        DispatchQueue.main.async {
                            self.scrollViewFrame = frame
                        }
                        return Color.clear
                    }
                }
                .onAppear {
                    scrollAsset = viewModel.assets.last
                    proxy.scrollTo(scrollAsset?.localIdentifier)
                }
                .onChange(of: columnItemCount) { _ in
                    proxy.scrollTo(scrollAsset?.localIdentifier, anchor: .top)
                }
                .onChange(of: selectMode) { selectMode in
                    if selectMode {
                        UITabBar.hideTabBar(animated: false)
                    } else {
                        UITabBar.showTabBar(animated: false)
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .named("CARDCELLFRAME"))
                        .onChanged { gesture in
                            if !selectMode { return }
                            if !isEnableDragToSelect { isEnableDragToSelect = true; return }
                            guard self.scrollViewFrame.contains(gesture.location) else { return }
                            viewModel.dragingAssetSelect(startLocation: gesture.startLocation, currentLocation: gesture.location)
                        }
                        .onEnded { _ in
                            if !selectMode { return }
                            isEnableDragToSelect = false
                            viewModel.finishDragingAssetSelect()
                        }
                )
            }
            
            navigationBar()
        }
        .toolbar {
            if selectMode {
                ToolbarItemGroup(placement: .bottomBar) {
                    HStack {
                        Button {
                            print("share")
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                        
                        Button { } label: { Image(systemName: "square.and.arrow.up") }.opacity(0)
                        
                        let title = viewModel.selectedAssets.isEmpty ? "항목 선택" : "\(viewModel.selectedAssets.count)개의 항목 선택됨"
                        Text(title)
                            .font(.bold(fontSize: .body1))
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "trash")
                        }
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                    .disabled(viewModel.selectedAssets.isEmpty)
                }
            }
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
                selectMode.toggle()
                viewModel.selectedAssets.removeAll()
            } label: {
                Text(selectMode ? "취소" : "선택")
                    .font(.medium(fontSize: .caption1))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 1000).fill(.gray)
                    )
            }
            .padding(.trailing, 4)
            
            if !selectMode {
                navigationBarMenuButton()
            }
        }
        .padding(.horizontal, 16)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.6), Color.clear]), startPoint: .top, endPoint: .bottom)
        )
    }
    
    @ViewBuilder
    private func navigationBarMenuButton() -> some View {
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
}

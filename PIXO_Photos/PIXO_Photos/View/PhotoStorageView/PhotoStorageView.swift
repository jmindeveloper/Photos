//
//  PhotoStorageView.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/7/24.
//

import SwiftUI
import Photos

struct PhotoStorageView<VM: PhotoStorageViewModelProtocol>: View {
    @ObservedObject var viewModel: VM
    @State var columnItemCount: Int = 3
    @State var scrollAsset: PHAsset?
    @State var cellContentMode: ContentMode = ContentMode.fill
    @State var isEnableDragToSelect: Bool = false
    @State var isPresentAlbumGridView: Bool = false
    @State var isAppeared: Bool = false
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollViewReader { proxy in
                ScrollView {
                    Color.clear
                        .frame(height: 100)
                    
                    PhotoGridView<PhotoStorageViewModel>(
                        columnItemCount: $columnItemCount,
                        cellContentMode: $cellContentMode,
                        viewModel: viewModel as! PhotoStorageViewModel
                    ) { asset in
                        handleAssetAppear(asset: asset)
                    } cellOnDisappearAction: { asset in
                        handleAssetDisAppear(asset: asset)
                    }
                    
                    if !viewModel.selectMode {
                        Text("\(viewModel.imageCount)장의 사진, \(viewModel.videoCount)개의 비디오")
                            .font(.system(size: 17, weight: .semibold))
                            .padding(.vertical, 10)
                    }
                }
                .scrollDisabled(isEnableDragToSelect)
                .coordinateSpace(name: "CARDCELLFRAME")
                .onAppear {
                    if !isAppeared {
                        scrollAsset = viewModel.assets.last
                        proxy.scrollTo(scrollAsset?.localIdentifier)
                        isAppeared = true
                    }
                }
                .onChange(of: viewModel.assets) {
                    if viewModel.isGetAssets {
                        scrollAsset = viewModel.assets.last
                        proxy.scrollTo(scrollAsset?.localIdentifier)
                        viewModel.isGetAssets = false
                    }
                }
                .onChange(of: columnItemCount) { _ in
                    proxy.scrollTo(scrollAsset?.localIdentifier, anchor: .top)
                }
                .onChange(of: viewModel.selectMode) { selectMode in
                    if selectMode {
                        UITabBar.hideTabBar(animated: false)
                    } else {
                        UITabBar.showTabBar(animated: false)
                    }
                }
                .gesture(dragSelectionGesture())
            }
            
            navigationBar()
        }
        .toolbar {
            if viewModel.selectMode {
                ToolbarItemGroup(placement: .bottomBar) {
                    bottomToolbarItems()
                }
            }
        }
    }
    
    // MARK: - SubViews
    @ViewBuilder
    private func navigationBar() -> some View {
        HStack(alignment: .top) {
            Text(viewModel.dateRangeString)
                .font(.bold(fontSize: .subHead2))
                .foregroundColor(.white)
            Spacer()
            
            Button {
                viewModel.selectMode.toggle()
                viewModel.selectedAssets.removeAll()
            } label: {
                Text(viewModel.selectMode ? "취소" : "선택")
                    .font(.medium(fontSize: .caption1))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 1000).fill(.gray)
                    )
            }
            .padding(.trailing, 4)
            
            if !viewModel.selectMode {
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
                cellContentMode.toggle()
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
    
    @ViewBuilder
    private func imageSelectMenuButton() -> some View {
        Menu {
            Group {
                Button {
                    isPresentAlbumGridView = true
                } label: {
                    Label("앨범에 추가", systemImage: "rectangle.stack.badge.plus")
                }
            }
            
            Group {
                Button {
                    viewModel.duplicateSelectedAssets()
                } label: {
                    Label("복제", systemImage: "plus.square.on.square")
                }
                
                Button {
                    viewModel.setFavoriteSelectedAssets()
                } label: {
                    Label("즐겨찾기", systemImage: "heart")
                }
                
                Button {
                    viewModel.copySelectedImageToClipboard()
                } label: {
                    Label("복사", systemImage: "doc.on.doc")
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
        .sheet(isPresented: $isPresentAlbumGridView) {
            NavigationView {
                UserAlbumGridView<PhotoStorageViewModel>(viewModel: viewModel as! PhotoStorageViewModel, isNavigate: false) { album in
                    viewModel.addAssetsToAlbum(albumName: album.title)
                    isPresentAlbumGridView = false
                }
                .navigationTitle("앨범에 추가")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    @ViewBuilder
    private func bottomToolbarItems() -> some View {
        HStack {
            Button {
                viewModel.getSelectedAssetsImage { images in
                    present(view: ActivityView(activityItmes: images))
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
            
            Button { } label: { Image(systemName: "square.and.arrow.up") }.opacity(0)
            
            Text(viewModel.selectedAssetsTitle)
                .font(.bold(fontSize: .body1))
                .frame(maxWidth: .infinity, alignment: .center)
            
            Button {
                viewModel.deleteSelectedAssets()
            } label: {
                Image(systemName: "trash")
            }
            
            imageSelectMenuButton()
        }
        .disabled(viewModel.selectedAssets.isEmpty)
    }
    
    // MARK: - Gesture
    private func dragSelectionGesture() -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named("CARDCELLFRAME"))
            .onChanged { gesture in
                guard viewModel.selectMode else { return }
                if !isEnableDragToSelect {
                    isEnableDragToSelect = true
                    return
                }
                viewModel.draggingAssetSelect(startLocation: gesture.startLocation, currentLocation: gesture.location)
            }
            .onEnded { _ in
                guard viewModel.selectMode else { return }
                isEnableDragToSelect = false
                viewModel.finishDraggingAssetSelect()
            }
    }
    
    // MARK: - Method
    private func handleAssetAppear(asset: PHAsset) {
        if let date = asset.creationDate {
            scrollAsset = asset
            viewModel.visibleAssetsDate.append(date)
        }
    }
    
    private func handleAssetDisAppear(asset: PHAsset) {
        if let date = asset.creationDate {
            viewModel.visibleAssetsDate.removeAll {
                $0 == date
            }
        }
    }
}

//
//  PhotoGridView.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/7/24.
//

import SwiftUI
import Photos

protocol PhotoGridViewModelProtocol: ObservableObject {
    var assets: [PHAsset] { get set }
    var assetWithFrame: [(asset: PHAsset, frame: CGRect)] { get set }
    var selectedAssets: Set<PHAsset> { get set }
    var selectMode: Bool { get set }
    
    func setAssetFrame(index: Int, rect: CGRect)
    func dragingAssetSelect(startLocation: CGPoint, currentLocation: CGPoint)
    func finishDragingAssetSelect()
}

struct PhotoGridView<VM: PhotoGridViewModelProtocol>: View {
    @EnvironmentObject var viewModel: VM
    
    @Binding var columnItemCount: Int
    @Binding var cellContentMode: ContentMode
    
    private let spacingWidth: CGFloat = 1
    
    var cellOnAppearAction: ((_ asset: PHAsset) -> Void)
    var cellOnDisappearAction: ((_ asset: PHAsset) -> Void)
    
    init(
        columnItemCount: Binding<Int>,
        cellContentMode: Binding<ContentMode>,
        cellOnAppearAction: @escaping (_ asset: PHAsset) -> Void = { _ in },
        cellOnDisappearAction: @escaping (_ asset: PHAsset) -> Void = { _ in }
    ) {
        self._columnItemCount = columnItemCount
        self.cellOnAppearAction = cellOnAppearAction
        self.cellOnDisappearAction = cellOnDisappearAction
        self._cellContentMode = cellContentMode
    }
    
    var body: some View {
        let gridItem = Array(
            repeating: GridItem(.flexible(), spacing: spacingWidth),
            count: columnItemCount
        )
        LazyVGrid(columns: gridItem, spacing: spacingWidth) {
            ForEach(0..<viewModel.assets.count, id: \.self) { index in
                let asset = viewModel.assets[index]
                PhotoCell(asset: asset)
                    .contentMode(cellContentMode)
                    .isSelected(viewModel.selectedAssets.contains(asset))
                    .aspectRatio(1, contentMode: .fit)
                    .id(asset.localIdentifier)
                    .overlay {
                        GeometryReader { proxy -> Color in
                            let frame = proxy.frame(in: .named("CARDCELLFRAME"))
                            viewModel.setAssetFrame(index: index, rect: frame)
                            return Color.clear
                        }
                    }
                    .onAppear {
                        cellOnAppearAction(asset)
                    }
                    .onDisappear {
                        cellOnDisappearAction(asset)
                    }
                    .onTapGesture {
                        if viewModel.selectMode {
                            if viewModel.selectedAssets.contains(asset) {
                                viewModel.selectedAssets.remove(asset)
                            } else {
                                viewModel.selectedAssets.insert(asset)
                            }
                        }
                    }
            }
        }
    }
}

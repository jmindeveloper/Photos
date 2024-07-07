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
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical) {
                PhotoGridView(assets: $viewModel.assets)
                
                Text("\(viewModel.imageCount)장의 사진, \(viewModel.videoCount)개의 비디오")
                    .font(.system(size: 17, weight: .semibold))
                    .padding(.vertical, 10)
                    .id("SCROLLVIEW_BOTTOM")
            }
            .onAppear {
                proxy.scrollTo("SCROLLVIEW_BOTTOM")
            }
        }
    }
}

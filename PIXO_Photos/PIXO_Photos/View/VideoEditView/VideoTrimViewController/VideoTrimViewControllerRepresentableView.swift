//
//  VideoEditViewControllerRepresentableView.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/9/24.
//

import SwiftUI

struct VideoTrimViewControllerRepresentableView<VM: VideoEditViewModelProtocol>: UIViewControllerRepresentable {
    @EnvironmentObject var viewModel: VM
    let viewController = VideoTrimViewController()
    
    func makeUIViewController(context: Context) -> VideoTrimViewController {
        viewController.setViewModel(viewModel: viewModel)
        viewModel.getVideoAsset()
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: VideoTrimViewController, context: Context) {
        
    }
}

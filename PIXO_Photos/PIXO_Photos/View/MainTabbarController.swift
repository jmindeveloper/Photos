//
//  MainTabbarController.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/7/24.
//

import UIKit
import SwiftUI

final class MainTabbarController: UITabBarController {
    let library = PhotoLibrary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabbar()
    }
    
    private func setTabbarControllerItem(view: some View, title: String, image: UIImage) -> UIViewController {
        let viewController: UIViewController = UIHostingController(rootView: view)
        
        viewController.tabBarItem.title = title
        viewController.tabBarItem.image = image
        
        return viewController
    }
    
    private func configureTabbar() {
        let photoStorageViewModel = PhotoStorageViewModel(library: library)
        let albumViewModel = AlbumViewModel(library: library)
        
        let photoVC = setTabbarControllerItem(
            view: PhotoStorageView<PhotoStorageViewModel>().environmentObject(photoStorageViewModel),
            title: "보관함",
            image: UIImage(systemName: "photo.stack") ?? UIImage()
        )
        let albumVC = setTabbarControllerItem(
            view: AlbumView().environmentObject(albumViewModel),
            title: "앨범",
            image: UIImage(systemName: "square.stack.fill") ?? UIImage()
        )
        
        setViewControllers([photoVC, albumVC], animated: true)
    }
}

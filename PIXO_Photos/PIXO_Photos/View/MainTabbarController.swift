//
//  MainTabbarController.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/7/24.
//

import UIKit
import SwiftUI

final class MainTabbarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabbar()
    }
    
    private func setTabbarControllerItem(view: some View, title: String, image: UIImage, isNavigation: Bool) -> UIViewController {
        let viewController: UIViewController
        if isNavigation {
            viewController = UINavigationController(rootViewController: UIHostingController(rootView: view))
        } else {
            viewController = UIHostingController(rootView: view)
        }
        
        viewController.tabBarItem.title = title
        viewController.tabBarItem.image = image
        
        return viewController
    }
    
    private func configureTabbar() {
        let photoVC = setTabbarControllerItem(
            view: PhotoStorageView(),
            title: "보관함",
            image: UIImage(systemName: "photo.stack") ?? UIImage(),
            isNavigation: false
        )
        let albumVC = setTabbarControllerItem(
            view: AlbumView(),
            title: "앨범",
            image: UIImage(systemName: "square.stack.fill") ?? UIImage(),
            isNavigation: false
        )
        
        setViewControllers([photoVC, albumVC], animated: true)
    }
}

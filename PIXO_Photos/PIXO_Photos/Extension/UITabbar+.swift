//
//  UITabbar+.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/7/24.
//

import UIKit

extension UITabBar {
    static func showTabBar(animated: Bool = true) {
        DispatchQueue.main.async {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            windowScene?.windows.first(where: { $0.isKeyWindow })?.allSubviews().forEach({ (v) in
                if let view = v as? UITabBar {
                    view.setIsHidden(false, animated: animated)
                }
            })
        }
    }
    
    // if tab View is used hide Tab Bar
    static func hideTabBar(animated: Bool = true) {
        DispatchQueue.main.async {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            windowScene?.windows.first(where: { $0.isKeyWindow })?.allSubviews().forEach({ (v) in
                if let view = v as? UITabBar {
                    view.setIsHidden(true, animated: animated)
                }
            })
        }
    }

    private static func updateFrame(_ view: UIView) {
        if let sv =  view.superview {
            let currentFrame = sv.frame
            sv.frame = currentFrame.insetBy(dx: 0, dy: 1)
            sv.frame = currentFrame
        }
    }
    
    private func setIsHidden(_ hidden: Bool, animated: Bool) {
        let isViewHidden = self.isHidden
        
        if animated {
            if self.isHidden && !hidden {
                self.isHidden = false
                Self.updateFrame(self)
                self.frame.origin.y = UIScreen.main.bounds.height + 200
            }
            
            if isViewHidden && !hidden {
                self.alpha = 0.0
            }
            
            UIView.animate(withDuration: 0.8, animations: {
                self.alpha = hidden ? 0.0 : 1.0
            })
            UIView.animate(withDuration: 0.6, animations: {
                
                if !isViewHidden && hidden {
                    self.frame.origin.y = UIScreen.main.bounds.height + 200
                }
                else if isViewHidden && !hidden {
                    self.frame.origin.y = UIScreen.main.bounds.height - self.frame.height
                }
            }) { _ in
                if hidden && !self.isHidden {
                    self.isHidden = true
                    Self.updateFrame(self)
                }
            }
        } else {
            if !isViewHidden && hidden {
                self.frame.origin.y = UIScreen.main.bounds.height + 200
            }
            else if isViewHidden && !hidden {
                self.frame.origin.y = UIScreen.main.bounds.height - self.frame.height
            }
            self.isHidden = hidden
            Self.updateFrame(self)
            self.alpha = 1
        }
    }
}

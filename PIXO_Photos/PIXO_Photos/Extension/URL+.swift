//
//  URL+.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/11/24.
//

import UIKit

extension URL {
    func getUIImage() -> UIImage? {
        guard let data = try? Data(contentsOf: self),
              let image = UIImage(data: data) else {
            return nil
        }
        
        return image
    }
}

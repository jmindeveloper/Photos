//
//  Album.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/9/24.
//

import Foundation
import Photos

struct Album: Identifiable, Hashable {
    var id: String
    let title: String
    var assets: [PHAsset]
    var assetCount: Int
    let fetchResult: PHFetchResult<PHAsset>
}

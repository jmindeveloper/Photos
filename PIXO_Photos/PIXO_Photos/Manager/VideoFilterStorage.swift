//
//  VideoFilterStorage.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/10/24.
//

import Foundation

final class VideoFilterStorage {
    
    static func saveFilter(id: String, filter: FilterValue) {
        UserDefaults.standard.setValue(filter, forKey: id)
    }
    
    static func getFilter(id: String) -> FilterValue? {
        UserDefaults.standard.dictionary(forKey: id) as? FilterValue
    }
    
    private init() { }
    
}

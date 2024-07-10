//
//  PhotoEXIFView.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/10/24.
//

import SwiftUI

struct PhotoEXIFView: View {
    @Binding var exifData: [String: Any]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 10) {
                let _ = print(exifData)
                let _ = print(exifData)
                
                if let date = exifData["DateTimeOriginal"] as? String {
                    Text(date)
                        .font(.semibold(fontSize: .body2))
                }
                
                Divider()
                
                if let lens = exifData["LensModel"] as? String {
                    Text(lens)
                        .font(.semibold(fontSize: .body2))
                }
                
                Divider()
                
                HStack {
                    if let iso = exifData["ISOSpeedRatings"] as? [Int], let isoValue = iso.first {
                        Text("ISO \(isoValue)")
                            .font(.semibold(fontSize: .body2))
                    }
                    
                    Spacer()
                    
                    Divider().frame(height: 20)
                    
                    Spacer()
                    
                    if let focalLength = exifData["FocalLength"] as? Double {
                        Text("\(String(format: "%.1f", focalLength)) mm")
                            .font(.semibold(fontSize: .body2))
                    }
                    
                    Spacer()
                    
                    Divider().frame(height: 20)
                    
                    Spacer()
                    
                    if let brightness = exifData["ExposureBiasValue"] as? Double {
                        Text("\(String(format: "%.1f", brightness)) ev")
                            .font(.semibold(fontSize: .body2))
                    }
                    
                    Spacer()
                    
                    Divider().frame(height: 20)
                    
                    Spacer()
                    
                    if let aperture = exifData["ApertureValue"] as? Double {
                        Text("f/\(String(format: "%.1f", aperture))")
                            .font(.semibold(fontSize: .body2))
                    }
                    
                    Spacer()
                    
                    Divider().frame(height: 20)
                    
                    Spacer()
                    
                    if let shutterSpeed = exifData["ShutterSpeedValue"] as? Double {
                        Text("\(String(format: "%.1f", shutterSpeed)) s")
                            .font(.semibold(fontSize: .body2))
                    }
                }
            }
            .padding()
            .background(Color.black)
            .foregroundColor(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding()
        }
    }
}


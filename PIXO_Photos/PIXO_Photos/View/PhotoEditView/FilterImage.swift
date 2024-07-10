//
//  FilterImage.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/9/24.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct FilterImage: View {
    var inputImage: UIImage
    var contentMode: ContentMode = .fit
    var context = CIContext()
    
    // Saturation (채도)
    var saturation: Float
    // Hue (색조)
    var hue: Float
    // Exposure (노출)
    var exposure: Float
    // Brightness (휘도)
    var brightness: Float
    // Contrast (대비)
    var contrast: Float
    // Highlights (하이라이트)
    var highlights: Float
    // Shadows (그림자)
    var shadows: Float
    // Temperature (색온도)
    var temperature: Float
    // Sharpness (선명도)
    var sharpness: Float
    // 사진 앱 필터 이름
    var filterName: String
    
    init(
        inputImage: UIImage,
        contentMode: ContentMode = .fit,
        context: CIContext = CIContext(),
        saturation: Float,
        hue: Float,
        exposure: Float,
        brightness: Float,
        contrast: Float,
        highlights: Float,
        shadows: Float,
        temperature: Float,
        sharpness: Float,
        filterName: String
    ) {
        self.inputImage = inputImage
        self.contentMode = contentMode
        self.context = context
        self.saturation = saturation
        self.hue = hue
        self.exposure = exposure
        self.brightness = brightness
        self.contrast = contrast
        self.highlights = highlights
        self.shadows = shadows
        self.temperature = temperature
        self.sharpness = sharpness
        self.filterName = filterName
    }
    
    init(
        image: UIImage,
        contentMode: ContentMode = .fill,
        filter: FilterValue
    ) {
        self.init(
            inputImage: image,
            contentMode: contentMode,
            saturation: filter["saturation"] ?? 0,
            hue: filter["hue"] ?? 0,
            exposure: filter["exposure"] ?? 0,
            brightness: filter["brightness"] ?? 0,
            contrast: filter["contrast"] ?? 0,
            highlights: filter["highlights"] ?? 0,
            shadows: filter["shadows"] ?? 0,
            temperature: filter["temperature"] ?? 0,
            sharpness: filter["sharpness"] ?? 0,
            filterName: Filter.intToValue(Int(filter["filter"] ?? 0)).rawValue
        )
        print(filterName)
    }
    
    var body: some View {
        if let cgImage = inputImage.applyFilter(filter: getFilterValue(), context: context) {
            return Image(decorative: cgImage, scale: 1.0)
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } else {
            return Image(uiImage: inputImage)
                .resizable()
                .aspectRatio(contentMode: contentMode)
        }
    }
    
    func getFilterValue() -> FilterValue {
        [
            "saturation": saturation,
            "hue": hue,
            "exposure": exposure,
            "brightness": brightness,
            "contrast": contrast,
            "highlights": highlights,
            "shadows": shadows,
            "temperature": temperature,
            "sharpness": sharpness,
            "filter": Float((Filter(rawValue: filterName) ?? .Original).valueToInt())
        ]
    }
    
    func uiImage() -> UIImage? {
        guard let cgImage = inputImage.applyFilter(filter: getFilterValue(), context: context) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

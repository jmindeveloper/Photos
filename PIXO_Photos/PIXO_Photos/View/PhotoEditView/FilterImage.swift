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
    
    var body: some View {
        if let cgimg = applyFilters(to: inputImage) {
            return Image(decorative: cgimg, scale: 1.0)
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } else {
            return Image(uiImage: inputImage)
                .resizable()
                .aspectRatio(contentMode: contentMode)
        }
    }
    
    func applyFilters(to image: UIImage) -> CGImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        // Apply Color Controls filter
        let colorControls = CIFilter.colorControls()
        colorControls.inputImage = ciImage
        colorControls.saturation = saturation
        colorControls.brightness = brightness
        colorControls.contrast = contrast
        
        // Apply Hue Adjust filter
        let hueAdjust = CIFilter.hueAdjust()
        hueAdjust.inputImage = colorControls.outputImage
        hueAdjust.angle = hue
        
        // Apply Exposure Adjust filter
        let exposureAdjust = CIFilter.exposureAdjust()
        exposureAdjust.inputImage = hueAdjust.outputImage
        exposureAdjust.ev = exposure
        
        // Apply Highlight and Shadow Adjust filter
        let highlightShadowAdjust = CIFilter.highlightShadowAdjust()
        highlightShadowAdjust.inputImage = exposureAdjust.outputImage
        highlightShadowAdjust.highlightAmount = highlights
        highlightShadowAdjust.shadowAmount = shadows
        
        // Apply Temperature and Tint filter
        let temperatureAndTint = CIFilter.temperatureAndTint()
        temperatureAndTint.inputImage = highlightShadowAdjust.outputImage
        temperatureAndTint.neutral = CIVector(x: CGFloat(temperature), y: 0)
        
        // Apply Sharpen Luminance filter
        let sharpenLuminance = CIFilter.sharpenLuminance()
        sharpenLuminance.inputImage = temperatureAndTint.outputImage
        sharpenLuminance.sharpness = sharpness
        
        // Apply photo app filter if available
        var finalOutput = sharpenLuminance.outputImage
        if let photoAppFilter = getPhotoAppFilter(for: filterName, inputImage: finalOutput) {
            finalOutput = photoAppFilter.outputImage
        }
        
        guard let outputImage = finalOutput else { return nil }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            return cgimg
        } else {
            return nil
        }
    }
    
    func getPhotoAppFilter(for filterName: String, inputImage: CIImage?) -> CIFilter? {
        guard let inputImage = inputImage else { return nil }
        
        let filter: CIFilter?
        switch filterName {
        case "Mono":
            let monoFilter = CIFilter.photoEffectMono()
            monoFilter.inputImage = inputImage
            filter = monoFilter
        case "Tonal":
            let tonalFilter = CIFilter.photoEffectTonal()
            tonalFilter.inputImage = inputImage
            filter = tonalFilter
        case "Noir":
            let noirFilter = CIFilter.photoEffectNoir()
            noirFilter.inputImage = inputImage
            filter = noirFilter
        case "Fade":
            let fadeFilter = CIFilter.photoEffectFade()
            fadeFilter.inputImage = inputImage
            filter = fadeFilter
        case "Chrome":
            let chromeFilter = CIFilter.photoEffectChrome()
            chromeFilter.inputImage = inputImage
            filter = chromeFilter
        case "Process":
            let processFilter = CIFilter.photoEffectProcess()
            processFilter.inputImage = inputImage
            filter = processFilter
        case "Transfer":
            let transferFilter = CIFilter.photoEffectTransfer()
            transferFilter.inputImage = inputImage
            filter = transferFilter
        case "Instant":
            let instantFilter = CIFilter.photoEffectInstant()
            instantFilter.inputImage = inputImage
            filter = instantFilter
        default:
            filter = nil
        }
        
        return filter
    }
    
    func uiImage() -> UIImage? {
        guard let cgImage = applyFilters(to: inputImage) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

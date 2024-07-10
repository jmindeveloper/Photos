//
//  UIImage+.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/10/24.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

extension UIImage {
    func applyFilter(filter: FilterValue, context: CIContext) -> CGImage? {
        let saturation = filter["saturation"] ?? 0
        let hue = filter["hue"] ?? 0
        let exposure = filter["exposure"] ?? 0
        let brightness = filter["brightness"] ?? 0
        let contrast = filter["contrast"] ?? 0
        let highlights = filter["highlights"] ?? 0
        let shadows = filter["shadows"] ?? 0
        let temperature = filter["temperature"] ?? 0
        let sharpness = filter["sharpness"] ?? 0
        let filterName = Filter.intToValue(Int(filter["filter"] ?? 0)).rawValue
        
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
        
        guard let ciImage = CIImage(image: self) else { return nil }
        
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
}

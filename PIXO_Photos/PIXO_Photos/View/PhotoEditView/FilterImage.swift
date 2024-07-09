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

    var body: some View {
        if let cgimg = applyFilters(to: inputImage) {
            return Image(decorative: cgimg, scale: 1.0)
                .resizable()
                .scaledToFit()
        } else {
            return Image(uiImage: inputImage)
                .resizable()
                .scaledToFit()
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

        guard let outputImage = sharpenLuminance.outputImage else { return nil }

        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            return cgimg
        } else {
            return nil
        }
    }
}

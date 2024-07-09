//
//  PhotoEditViewModel.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/9/24.
//

import UIKit
import Photos
import Combine

final class PhotoEditViewModel: ObservableObject {
    enum EditMode: CaseIterable {
        case Adjust
        case Filter
//        case Crop
        
        var imageName: String {
            switch self {
            case .Filter:
                return "camera.filters"
            case .Adjust:
                return "slider.horizontal.3"
//            case .Crop:
//                return "crop.rotate"
            }
        }
        
        var title: String {
            switch self {
            case .Filter:
                return "필터"
            case .Adjust:
                return "조절"
//            case .Crop:
//                return "자르기"
            }
        }
    }
    
    enum AdjustEffect: String, CaseIterable {
        // Exposure (노출)
        case Exposure
        // Saturation (채도)
        case Saturation
        // Hue (색조)
        case Hue
        // Brightness (휘도)
        case Brightness
        // Contrast (대비)
        case Contrast
        // Highlights (하이라이트)
        case Highlights
        // Shadows (그림자)
        case Shadows
        // Temperature (색온도)
        case Temperature
        // Sharpness (선명도)
        case Sharpness
        
        var imageName: String {
            switch self {
            case .Saturation:
                return "s.circle"
            case .Hue:
                return "drop"
            case .Exposure:
                return "plusminus.circle"
            case .Brightness:
                return "swirl.circle.righthalf.filled"
            case .Contrast:
                return "circle.righthalf.filled.inverse"
            case .Highlights:
                return "circle.lefthalf.striped.horizontal.inverse"
            case .Shadows:
                return "circle.lefthalf.filled.righthalf.striped.horizontal.inverse"
            case .Temperature:
                return "thermometer.low"
            case .Sharpness:
                return "righttriangle.fill"
            }
        }
        
        var title: String {
            switch self {
            case .Saturation:
                return "채도"
            case .Hue:
                return "색조"
            case .Exposure:
                return "노출"
            case .Brightness:
                return "휘도"
            case .Contrast:
                return "대비"
            case .Highlights:
                return "하이라이트"
            case .Shadows:
                return "그림자"
            case .Temperature:
                return "색온도"
            case .Sharpness:
                return "선명도"
            }
        }
        
        var minValue: Float {
            switch self {
            case .Exposure:
                return -3
            case .Saturation:
                return 0
            case .Hue:
                return -Float.pi
            case .Brightness:
                return -1
            case .Contrast:
                return 0.5
            case .Highlights:
                return 0
            case .Shadows:
                return -1
            case .Temperature:
                return 2000
            case .Sharpness:
                return -2
            }
        }
        
        var maxValue: Float {
            switch self {
            case .Exposure:
                return 3
            case .Saturation:
                return 2
            case .Hue:
                return Float.pi
            case .Brightness:
                return 1
            case .Contrast:
                return 1.5
            case .Highlights:
                return 1
            case .Shadows:
                return 1
            case .Temperature:
                return 10000
            case .Sharpness:
                return 2
            }
        }
    }
    
    enum Filter: String, CaseIterable {
        case Original, Mono, Tonal, Noir, Fade, Chrome, Process, Transfer, Instant
        
        static func intToValue(_ v: Int) -> Filter {
            switch v {
            case 0:
                return .Original
            case 1:
                return .Mono
            case 2:
                return .Tonal
            case 3:
                return .Noir
            case 4:
                return .Fade
            case 5:
                return .Chrome
            case 6:
                return .Process
            case 7:
                return .Transfer
            case 8:
                return .Instant
            default:
                return .Original
            }
        }
        
        func valueToInt() -> Int {
            switch self {
            case .Original:
                return 0
            case .Mono:
                return 1
            case .Tonal:
                return 2
            case .Noir:
                return 3
            case .Fade:
                return 4
            case .Chrome:
                return 5
            case .Process:
                return 6
            case .Transfer:
                return 7
            case .Instant:
                return 8
            }
        }
    }
    
    @Published var editMode: EditMode = .Adjust
    @Published var editAsset: PHAsset
    @Published var currentFilter: Filter = .Original
    @Published var currentAdjustEffect: AdjustEffect = .Exposure {
        didSet {
            currentAdjustMin = currentAdjustEffect.minValue
            currentAdjustMax = currentAdjustEffect.maxValue
            setCurrentAdjustEffectValue()
        }
    }
    
    @Published var saturation: Float = 1
    @Published var hue: Float = 0
    @Published var exposure: Float = 0
    @Published var brightness: Float = 0
    @Published var contrast: Float = 1
    @Published var highlights: Float = 1
    @Published var shadows: Float = 0
    @Published var temperature: Float = 6500
    @Published var sharpness: Float = 0
    
    @Published var currentAdjustMin: Float = AdjustEffect.Exposure.minValue
    @Published var currentAdjustMax: Float = AdjustEffect.Exposure.maxValue
    @Published var currentAdjustEffectValue: Float = 0
    
    @Published var backwardHistory: [[String: Float]] = []
    @Published var forwardHistory: [[String: Float]] = []
    
    @Published var updateSlider: Bool = false
    
    var backwardHistoryEmpty: Bool {
        backwardHistory.count <= 1
    }
    
    var forwardHistoryEmpty: Bool {
        forwardHistory.isEmpty
    }
    
    private var isLoadHistory: Bool = false
    
    var context = CIContext()
    private var subscriptions = Set<AnyCancellable>()
    
    init(editAsset: PHAsset) {
        self.editAsset = editAsset
        saveHistory()
        
        binding()
    }
    
    private func binding() {
        $saturation
            .merge(with: $hue)
            .merge(with: $exposure)
            .merge(with: $brightness)
            .merge(with: $contrast)
            .merge(with: $highlights)
            .merge(with: $shadows)
            .merge(with: $temperature)
            .merge(with: $sharpness)
            .combineLatest($currentFilter)
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else {
                    return
                }
                if isLoadHistory {
                    isLoadHistory = false
                    return
                }
                saveHistory()
                forwardHistory.removeAll()
            }.store(in: &subscriptions)
    }
    
    func changeAdjustEffectValue(_ value: Float) {
        switch currentAdjustEffect {
        case .Exposure:
            exposure = value
        case .Saturation:
            saturation = value
        case .Hue:
            hue = value
        case .Brightness:
            brightness = value
        case .Contrast:
            contrast = value
        case .Highlights:
            highlights = value
        case .Shadows:
            shadows = value
        case .Temperature:
            temperature = value
        case .Sharpness:
            sharpness = value
        }
    }
    
    func saveHistory() {
        var history: [String: Float] = [:]
        
        history["saturation"] = saturation
        history["hue"] = hue
        history["exposure"] = exposure
        history["brightness"] = brightness
        history["contrast"] = contrast
        history["highlights"] = highlights
        history["shadows"] = shadows
        history["temperature"] = temperature
        history["sharpness"] = sharpness
        history["filter"] = Float(currentFilter.valueToInt())
        
        if history == backwardHistory.last {
            return
        }
        
        backwardHistory.append(history)
    }
    
    func backward() {
        guard backwardHistory.count >= 2 else {
            return
        }
        isLoadHistory = true
        forwardHistory.append(backwardHistory.removeLast())
        
        if let history = backwardHistory.last {
            saturation = history["saturation"] ?? 0
            hue = history["hue"] ?? 0
            exposure = history["exposure"] ?? 0
            brightness = history["brightness"] ?? 0
            contrast = history["contrast"] ?? 0
            highlights = history["highlights"] ?? 0
            shadows = history["shadows"] ?? 0
            temperature = history["temperature"] ?? 0
            sharpness = history["sharpness"] ?? 0
            currentFilter = Filter.intToValue(Int(history["filter"] ?? 0))
            
            setCurrentAdjustEffectValue()
        }
    }
    
    func forward() {
        guard !forwardHistory.isEmpty else {
            return
        }
        
        isLoadHistory = true
        let history = forwardHistory.removeFirst()
        backwardHistory.append(history)
        
        saturation = history["saturation"] ?? 0
        hue = history["hue"] ?? 0
        exposure = history["exposure"] ?? 0
        brightness = history["brightness"] ?? 0
        contrast = history["contrast"] ?? 0
        highlights = history["highlights"] ?? 0
        shadows = history["shadows"] ?? 0
        temperature = history["temperature"] ?? 0
        sharpness = history["sharpness"] ?? 0
        currentFilter = Filter.intToValue(Int(history["filter"] ?? 0))
        
        setCurrentAdjustEffectValue()
    }
    
    func setCurrentAdjustEffectValue() {
        switch currentAdjustEffect {
        case .Exposure:
            currentAdjustEffectValue = exposure
        case .Saturation:
            currentAdjustEffectValue = saturation
        case .Hue:
            currentAdjustEffectValue = hue
        case .Brightness:
            currentAdjustEffectValue = brightness
        case .Contrast:
            currentAdjustEffectValue = contrast
        case .Highlights:
            currentAdjustEffectValue = highlights
        case .Shadows:
            currentAdjustEffectValue = shadows
        case .Temperature:
            currentAdjustEffectValue = temperature
        case .Sharpness:
            currentAdjustEffectValue = sharpness
        }
        updateSlider = true
    }
    
    func saveImage(image: UIImage, completion: @escaping (() -> Void)) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { success, _ in
            if success {
                completion()
            } else {
                fatalError("이미지 저장 실패")
            }
        }
    }
}

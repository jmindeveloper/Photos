//
//  FilterManager.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/10/24.
//

import Foundation
import CoreImage
import Combine

protocol FilterManagerProtocol: ObservableObject {
    var currentFilter: Filter { get set }
    var currentAdjustEffect: AdjustEffect { get set }
    var saturation: Float { get set }
    var hue: Float { get set }
    var exposure: Float { get set }
    var brightness: Float { get set }
    var contrast: Float { get set }
    var highlights: Float { get set }
    var shadows: Float { get set }
    var temperature: Float { get set }
    var sharpness: Float { get set }
    var currentAdjustMin: Float { get set }
    var currentAdjustMax: Float { get set }
    var currentAdjustEffectValue: Float { get set }
    var backwardHistory: [FilterValue] { get set }
    var forwardHistory: [FilterValue] { get set }
    var updateSlider: Bool { get set }
    var backwardHistoryEmpty: Bool { get }
    var forwardHistoryEmpty: Bool { get }
    var context: CIContext { get set }
    
    func changeAdjustEffectValue(_ value: Float)
    func backward()
    func forward()
}

class FilterManager: FilterManagerProtocol {
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
    
    @Published var backwardHistory: [FilterValue] = []
    @Published var forwardHistory: [FilterValue] = []
    
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
    
    init() {
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
}

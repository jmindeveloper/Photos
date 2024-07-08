//
//  View+.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/7/24.
//

import SwiftUI

extension View {
    func readFrame(name: String, onChange: @escaping (CGRect) -> Void) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: proxy.frame(in: .named(name)))
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
    
    func present(view: some View, modalStyle: UIModalPresentationStyle = .automatic, animated: Bool = true) {
        let vc = UIHostingController(rootView: view)
        vc.modalPresentationStyle = .fullScreen
        UIApplication.topViewController()?.present(vc, animated: animated)
    }
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {}
}


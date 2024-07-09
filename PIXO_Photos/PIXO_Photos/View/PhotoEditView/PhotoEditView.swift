//
//  PhotoEditView.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/9/24.
//

import SwiftUI

struct PhotoEditView: View {
    @EnvironmentObject var viewModel: PhotoEditViewModel
    @State var uiImage: UIImage?
    
    var body: some View {
        VStack {
            
            saveCancelView()
            
            toolBar()
                .padding(.top, 5)
            
            Spacer()
            
            if let image = uiImage {
                ZStack(alignment: .bottom) {
                    FilterImage(
                        inputImage: image,
                        saturation: viewModel.saturation,
                        hue: viewModel.hue,
                        exposure: viewModel.exposure,
                        brightness: viewModel.brightness,
                        contrast: viewModel.contrast,
                        highlights: viewModel.highlights,
                        shadows: viewModel.shadows,
                        temperature: viewModel.temperature,
                        sharpness: viewModel.sharpness
                    )
                    
                    Text(viewModel.currentAdjustEffect.title)
                        .padding(4)
                        .background {
                            RoundedRectangle(cornerRadius: 4).fill(.gray)
                        }
                        .padding(.bottom, 10)
                }
            }
            
            Spacer()
            
            selectEffectView()
            
            ScrollSlider(
                currentValue: $viewModel.currentAdjustEffectValue,
                min: $viewModel.currentAdjustMin,
                max: $viewModel.currentAdjustMax
            ) { value in
                viewModel.changeAdjustEffectValue(value)
            }
            .padding(.horizontal, 20)
            
            selectEditModeView()
                .padding(.top, 3)
        }
        .onAppear {
            PhotoLibrary.requestImageURL(with: viewModel.editAsset) { url in
                let data = try? Data(contentsOf: url)
                let image = UIImage(data: data ?? Data())
                uiImage = image
            }
        }
    }
    
    @ViewBuilder
    private func saveCancelView() -> some View {
        HStack {
            Button {
                
            } label: {
                Text("취소")
                    .foregroundColor(.black)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 10000)
                            .fill(Color.gray)
                    )
            }
            
            Spacer()
            
            Button {
                
            } label: {
                Text("완료")
                    .foregroundColor(.black)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 10000)
                            .fill(Color.yellow)
                    )
            }
        }
        .padding(.horizontal, 35)
    }
    
    @ViewBuilder
    private func toolBar() -> some View {
        ZStack {
            HStack {
                Button {
                    print("move before step")
                } label: {
                    Image(systemName: "arrowshape.turn.up.backward.circle")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 4)
                
                Button {
                    print("move forward step")
                } label: {
                    Image(systemName: "arrowshape.turn.up.forward.circle")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            Text("조절")
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
        .frame(height: 35)
    }
    
    @ViewBuilder
    private func selectEffectView() -> some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 30) {
                    Color.clear.frame(width: Constant.SCREEN_WIDTH / 2 - 45)
                    ForEach(PhotoEditViewModel.AdjustEffect.allCases, id: \.self) { effect in
                        Image(systemName: effect.imageName)
                            .resizable()
                            .frame(width: 17, height: 17)
                            .foregroundColor(Color(uiColor: .label))
                            .padding(13)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke().foregroundColor(.gray)
                            )
                            .contentShape(Circle())
                            .onTapGesture {
                                viewModel.currentAdjustEffect = effect
                            }
                            .id(effect.title)
                    }
                    Color.clear.frame(width: Constant.SCREEN_WIDTH / 2 - 45)
                }
                .onChange(of: viewModel.currentAdjustEffect) {
                    withAnimation {
                        proxy.scrollTo(viewModel.currentAdjustEffect.title, anchor: .center)
                    }
                }
            }
            .frame(height: 55)
        }
    }
    
    @ViewBuilder
    private func selectEditModeView() -> some View {
        HStack(spacing: 30) {
            Spacer()
            
            ForEach(PhotoEditViewModel.EditMode.allCases, id: \.self) { mode in
                Button {
                    viewModel.editMode = mode
                } label: {
                    VStack {
                        Image(systemName: mode.imageName)
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.gray)
                        
                        Text(mode.title)
                            .foregroundStyle(.gray)
                    }
                }
            }
            
            Spacer()
        }
    }
}

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
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
            
            Spacer()
            
            selectEffectView()
            
            ScrollSlider()
                .padding(.horizontal, 20)
            
            selectEditModeView()
                .padding(.top, 3)
        }
        .onAppear {
            PhotoLibrary.requestImage(with: viewModel.editAsset) { image, _ in
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
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 30) {
                Color.clear.frame(width: 20)
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
                }
                Color.clear.frame(width: 20)
            }
        }
        .frame(height: 55)
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

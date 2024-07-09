//
//  PhotoEditView.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/9/24.
//

import SwiftUI

struct PhotoEditView: View {
    var body: some View {
        VStack {
            
            saveCancelView()
            
            toolBar()
                .padding(.top, 5)
            
            Spacer()
            
            Image(systemName: "heart")
                .resizable()
                .scaledToFit()
            
            Spacer()
            
            selectEffectView()
            
            ScrollSlider()
                .padding(.horizontal, 20)
            
            selectEditTypeView()
                .padding(.top, 3)
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
                ForEach(effects, id: \.self) { effect in
                    Image(systemName: effect.image)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color(uiColor: .label))
                        .padding(10)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke().foregroundColor(.gray)
                        )
                }
                Color.clear.frame(width: 20)
            }
        }
        .frame(height: 55)
    }
    
    @ViewBuilder
    private func selectEditTypeView() -> some View {
        HStack(spacing: 30) {
            Spacer()
            
            Button {
                
            } label: {
                VStack {
                    Image(systemName: "slider.horizontal.3")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.gray)
                    
                    Text("필터")
                        .foregroundStyle(.gray)
                }
            }
            
            Button {
                
            } label: {
                VStack {
                    Image(systemName: "camera.filters")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.gray)
                    
                    Text("조절")
                        .foregroundStyle(.gray)
                }
            }
            
            Button {
                
            } label: {
                VStack {
                    Image(systemName: "crop.rotate")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.gray)
                    
                    Text("자르기")
                        .foregroundStyle(.gray)
                }
            }
            
            Spacer()
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    PhotoEditView()
}


struct Effect: Identifiable, Hashable {
    var id = UUID().uuidString
    var title: String = ""
    var image: String = ""
}

var effects = [
    Effect(title: "밝기", image: "heart"),
    Effect(title: "노출", image: "heart"),
    Effect(title: "채도", image: "heart"),
    Effect(title: "휘도", image: "heart"),
    Effect(title: "대비", image: "heart"),
    Effect(title: "선명도", image: "heart"),
]

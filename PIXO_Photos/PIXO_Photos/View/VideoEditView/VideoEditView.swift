//
//  VideoEditView.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/9/24.
//

import SwiftUI

struct VideoEditView: View {
    @EnvironmentObject private var viewModel: VideoEditViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            
            saveCancelView()
            
            toolBar()
                .padding(.top, 5)
            
            Spacer()
            
            VideoTrimViewControllerRepresentableView()
                .environmentObject(viewModel)
            
            Spacer()
            
            selectEditModeView()
                .padding(.top, 3)
        }
        .onAppear {
        }
    }
    
    @ViewBuilder
    private func saveCancelView() -> some View {
        HStack {
            Button {
//                if viewModel.backwardHistoryEmpty {
                    presentationMode.wrappedValue.dismiss()
//                } else {
//                    AlertManager(message: "모든 변경사항을 폐기하겠습니까?", style: .actionSheet)
//                        .addAction(actionTitle: "변경사항 폐기", style: .destructive) { _ in
//                            presentationMode.wrappedValue.dismiss()
//                        }
//                        .addAction(actionTitle: "취소", style: .cancel)
//                        .present()
//                }
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
//                    .opacity(viewModel.backwardHistoryEmpty ? 0.8 : 1)
            }
//            .disabled(viewModel.backwardHistoryEmpty)
        }
        .padding(.horizontal, 35)
    }
    
    @ViewBuilder
    private func toolBar() -> some View {
        ZStack {
            HStack {
                Button {
//                    viewModel.backward()
                } label: {
                    Image(systemName: "arrowshape.turn.up.backward.circle")
                        .resizable()
                        .frame(width: 35, height: 35)
//                        .foregroundColor(viewModel.backwardHistoryEmpty ? .gray : .label)
                }
//                .disabled(viewModel.backwardHistoryEmpty)
                .padding(.trailing, 4)
                
                Button {
//                    viewModel.forward()
                } label: {
                    Image(systemName: "arrowshape.turn.up.forward.circle")
                        .resizable()
                        .frame(width: 35, height: 35)
//                        .foregroundColor(viewModel.forwardHistoryEmpty ? .gray : .label)
                }
//                .disabled(viewModel.forwardHistoryEmpty)
                
                Spacer()
            }
            
//            Text(viewModel.editMode.title)
//                .foregroundColor(.gray)
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
//                                viewModel.currentAdjustEffect = effect
                            }
                            .id(effect.title)
                    }
                    Color.clear.frame(width: Constant.SCREEN_WIDTH / 2 - 45)
                }
//                .onChange(of: viewModel.currentAdjustEffect) {
//                    withAnimation {
//                        proxy.scrollTo(viewModel.currentAdjustEffect.title, anchor: .center)
//                    }
//                }
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
//                    viewModel.editMode = mode
                } label: {
                    VStack {
                        Image(systemName: mode.imageName)
                            .resizable()
                            .frame(width: 20, height: 20)
//                            .foregroundColor(viewModel.editMode == mode ? .label : .gray)
                        
                        Text(mode.title)
//                            .foregroundColor(viewModel.editMode == mode ? .label : .gray)
                    }
                }
            }
            
            Spacer()
        }
    }
}

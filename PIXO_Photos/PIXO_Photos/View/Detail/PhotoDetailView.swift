//
//  PhotoDetailView.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/8/24.
//

import SwiftUI

struct PhotoDetailView: View {
    @EnvironmentObject var viewModel: PhotoDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        TabView {
            ZStack(alignment: .top) {
                PhotoDetailViewControllerRepresentableView()
                    .environmentObject(viewModel)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            viewModel.hiddenToolBar.toggle()
                        }
                    }
                
                VStack {
                    navigationBar()
                        .opacity(viewModel.hiddenToolBar ? 0 : 1)
                    
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    bottomToolbarItems()
                }
            }
            .onAppear {
                UITabBar.hideTabBar(animated: false)
            }
            .onDisappear {
                UITabBar.showTabBar(animated: false)
            }
        }
    }
    
    @ViewBuilder
    private func navigationBar() -> some View {
        HStack(alignment: .top) {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.blue)
                    .frame(width: 20, height: 20)
            }
            .frame(width: 40, height: 40)
            .contentShape(Rectangle())
            
            Text("편집").foregroundColor(.clear)
            
            Spacer()
           
            Text("6월 25일")
                .font(.bold(fontSize: .body1))
                .foregroundColor(.white)
                .frame(height: 40)
            
            Spacer()
            
            Button {
                
            } label: {
                Text("편집")
                    .font(.bold(fontSize: .body2))
            }
            .frame(height: 40)
            
            navigationBarMenuButton()
        }
        .padding(.horizontal, 16)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.clear]), startPoint: .top, endPoint: .bottom)
                .blur(radius: 0.8)
        )
    }
    
    @ViewBuilder
    private func navigationBarMenuButton() -> some View {
        Menu {
            
        } label: {
            Image(systemName: "ellipsis.circle")
                .resizable()
                .scaledToFit()
                .foregroundColor(.blue)
                .frame(width: 20, height: 20)
        }
        .frame(width: 40, height: 40)
        .contentShape(Rectangle())
    }
    
    @ViewBuilder
    private func bottomToolbarItems() -> some View {
        HStack {
            Button {
                viewModel.getCurrentAssetImage { images in
                    present(view: ActivityView(activityItmes: images))
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
            
            Spacer()
            
            Button {
                
            } label: {
                Image(systemName: "heart")
            }
            
            Spacer()
            
            Button {
                
            } label: {
                Image(systemName: "info.circle")
            }
            
            Spacer()
            
            Button {
                viewModel.deleteCurrentAsset()
            } label: {
                Image(systemName: "trash")
            }
        }
    }
}

//
//  PhotoDetailView.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/8/24.
//

import SwiftUI

struct PhotoDetailView<VM: PhotoDetailViewModelProtocol>: View {
    @StateObject var viewModel: VM
    @Environment(\.presentationMode) var presentationMode
    @State var isPresentAlbumGridView: Bool = false
    @State var isPresentEditView: Bool = false
    @State var isExifView: Bool = false
    
    var body: some View {
        TabView {
            ZStack(alignment: .top) {
                PhotoDetailViewControllerRepresentableView<PhotoDetailViewModel>(viewModel: viewModel as! PhotoDetailViewModel)
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
           
            Text(viewModel.dateString)
                .font(.bold(fontSize: .body1))
                .foregroundColor(.white)
                .frame(height: 40)
            
            Spacer()
            
            Button {
                isPresentEditView = true
                viewModel.isPlayVideo = false
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
        .fullScreenCover(isPresented: $isPresentEditView) {
            if viewModel.currentAsset.mediaType == .image {
                LazyView(
                    PhotoEditView<PhotoEditViewModel>(viewModel: PhotoEditViewModel(editAsset: viewModel.currentAsset))
                )
            } else {
                LazyView(
                    VideoEditView<VideoEditViewModel>(viewModel: VideoEditViewModel(editAsset: viewModel.currentAsset))
                )
            }
        }
    }
    
    @ViewBuilder
    private func navigationBarMenuButton() -> some View {
        Menu {
            Button {
                viewModel.duplicateCurrentAssets()
            } label: {
                Label("복제", systemImage: "plus.square.on.square")
            }
            
            Button {
                viewModel.copyCurrentImageToClipboard()
            } label: {
                Label("복사", systemImage: "doc.on.doc")
            }
            
            Button {
                isPresentAlbumGridView = true
            } label: {
                Label("앨범에 추가", systemImage: "rectangle.stack.badge.plus")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .resizable()
                .scaledToFit()
                .foregroundColor(.blue)
                .frame(width: 20, height: 20)
        }
        .frame(width: 40, height: 40)
        .contentShape(Rectangle())
        .sheet(isPresented: $isPresentAlbumGridView) {
            NavigationView {
                UserAlbumGridView<PhotoDetailViewModel>(viewModel: viewModel as! PhotoDetailViewModel, isNavigate: false) { album in
                    viewModel.addAssetsToAlbum(albumName: album.title)
                    isPresentAlbumGridView = false
                }
                .navigationTitle("앨범에 추가")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
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
                viewModel.setFavoriteCurrentAsset()
            } label: {
                Image(systemName: viewModel.currentAsset.isFavorite ? "heart.fill" : "heart")
            }
            
            Spacer()
            
            if viewModel.isVideo {
                Button {
                    viewModel.isPlayVideo.toggle()
                } label: {
                    Image(systemName: viewModel.isPlayVideo ? "pause.fill" : "play.fill")
                }
                
                Spacer()
            }
            
            Button {
                viewModel.getEXIFData {
                    isExifView = true
                }
            } label: {
                Image(systemName: "info.circle")
            }
            .sheet(isPresented: $isExifView) {
                PhotoEXIFView(exifData: $viewModel.currentAssetEXIF)
                    .presentationDetents([.height(200)])
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

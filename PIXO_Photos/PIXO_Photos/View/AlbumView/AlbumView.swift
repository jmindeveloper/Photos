//
//  AlbumView.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/7/24.
//

import SwiftUI

struct AlbumView<VM: AlbumViewModelProtocol>: View {
    
    @ObservedObject var viewModel: VM
    
    @State var rowCount: Int = 2
    @State var spacingWidth: CGFloat = 10
    
    var body: some View {
        NavigationView {
            ScrollView {
                Divider()
                
                myAlbumHeader()
                    .padding(.vertical, 4)
                    .padding(.horizontal, 16)
                
                GeometryReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        albumGridView(proxy: proxy)
                    }
                    .contentMargins(.horizontal, 16, for: .scrollContent)
                }
                .frame(height: 400)
                .padding(.bottom, 10)
                
                Divider()
                    .padding(.top, 4)
                
                mediaTypeSectionHeader()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                
                albumListView()
                    .padding(.horizontal, 16)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    addButton
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle("앨범")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Subviews
    @ViewBuilder
    private func myAlbumHeader() -> some View {
        HStack {
            Text("나의 앨범")
                .font(.bold(fontSize: .subHead2))
            
            Spacer()
            
            NavigationLink {
                UserAlbumGridView<AlbumViewModel>(viewModel: viewModel as! AlbumViewModel)
                    .navigationTitle("나의 앨범")
                    .navigationBarTitleDisplayMode(.inline)
            } label: {
                Text("전체보기")
            }
        }
    }
    
    @ViewBuilder
    private func albumGridView(proxy: GeometryProxy) -> some View {
        let gridItem = Array(repeating: GridItem(.flexible(), spacing: spacingWidth), count: rowCount)
        
        LazyHGrid(rows: gridItem, spacing: spacingWidth) {
            ForEach(viewModel.userAlbum, id: \.self) { album in
                NavigationLink {
                    LazyView(
                        PhotoStorageView<PhotoStorageViewModel>(viewModel: PhotoStorageViewModel(library: viewModel.library, album: album))
                            .navigationBarHidden(true)
                    )
                } label: {
                    AlbumCoverView(album: album)
                        .frame(width: proxy.size.width / 2 - 30)
                }
            }
        }
    }
    
    @ViewBuilder
    private func mediaTypeSectionHeader() -> some View {
        HStack {
            Text("미디어 유형")
                .font(.bold(fontSize: .subHead2))
            Spacer()
        }
    }
    
    @ViewBuilder
    private func albumListView() -> some View {
        LazyVStack {
            ForEach(viewModel.smartAlbum, id: \.self) { album in
                NavigationLink {
                    LazyView(
                        PhotoStorageView<PhotoStorageViewModel>(viewModel: PhotoStorageViewModel(library: viewModel.library, album: album))
                            .navigationBarHidden(true)
                    )
                } label: {
                    albumListCell(album: album, imageName: "heart")
                }
            }
        }
    }
    
    @ViewBuilder
    private func albumListCell(album: Album, imageName: String) -> some View {
        VStack(spacing: .zero) {
            HStack {
                Text(album.title)
                    .font(.medium(fontSize: .body1))
                    .foregroundColor(.blue)
                
                Spacer()
                
                Text(String(album.assetCount))
                    .foregroundColor(.gray)
                
                Image(systemName: "chevron.right")
                    .resizable()
                    .frame(width: 4, height: 8)
                    .foregroundColor(.gray)
            }
            
            Divider()
                .padding(.top, 12)
        }
        .frame(height: 40)
    }
    
    @ViewBuilder
    private var addButton: some View {
        Button {
            AlertManager(title: "새로운 앨범", message: "이 앨범의 이름을 입력하십시오.")
                .addTextField(placeHolder: "제목")
                .addAction(actionTitle: "저장", style: .default) { controller in
                    if let albumTitle = controller.textFields?.first?.text, !albumTitle.isEmpty {
                        viewModel.createAlbum(title: albumTitle)
                    }
                }
                .addAction(actionTitle: "취소", style: .cancel)
                .present()
        } label: {
            Image(systemName: "plus")
        }
    }
}

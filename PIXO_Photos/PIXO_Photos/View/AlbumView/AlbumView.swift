//
//  AlbumView.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/7/24.
//

import SwiftUI

struct AlbumView: View {
    
    @EnvironmentObject var viewModel: AlbumViewModel
    
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
                        let gridItem = Array(
                            repeating: GridItem(.flexible(), spacing: spacingWidth),
                            count: rowCount
                        )
                        
                        LazyHGrid(rows: gridItem, spacing: spacingWidth){
                            ForEach(viewModel.userAlbum, id: \.self) { album in
                                NavigationLink {
                                    let viewModel = PhotoStorageViewModel(
                                        library: self.viewModel.library,
                                        album: album
                                    )
                                    PhotoStorageView()
                                        .environmentObject(viewModel)
                                        .navigationBarHidden(true)
                                } label: {
                                    AlbumCoverView(album: album)
                                        .frame(width: proxy.size.width / 2 - 30)
                                }
                            }
                        }
                    }
                    .contentMargins(.horizontal, 16, for: .scrollContent)
                }
                .frame(height: 400)
                
                Divider()
                    .padding(.top, 4)
                
                HStack {
                    Text("미디어 유형")
                        .font(.bold(fontSize: .subHead2))
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
                
                LazyVStack {
                    ForEach(viewModel.smartAlbum, id: \.self) { album in
                        NavigationLink {
                            let viewModel = PhotoStorageViewModel(
                                library: self.viewModel.library,
                                album: album
                            )
                            PhotoStorageView()
                                .environmentObject(viewModel)
                                .navigationBarHidden(true)
                        } label: {
                            albumListCell(album: album, imageName: "heart")
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle("앨범")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    @ViewBuilder
    private func myAlbumHeader() -> some View {
        HStack {
            Text("나의 앨범")
                .font(.bold(fontSize: .subHead2))
            
            Spacer()
            
            Button {
                
            } label: {
                Text("전체보기")
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
}

struct AlbumCoverView: View {
    @State var album: Album
    @State var uiImage: UIImage? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            GeometryReader { proxy in
                if let image = uiImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .foregroundColor(.clear)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFill()
                        .foregroundColor(.gray)
                        .frame(width: 60, height: 60)
                        .clipped()
                        .position(x: proxy.frame(in: .local).midX, y: proxy.frame(in: .local).midY)
                }
            }
            
            Text(album.title)
                .foregroundColor(Color(uiColor: .label))
            
            Text("\(album.assetCount)")
                .foregroundColor(.gray)
        }
        .onAppear {
            PhotoLibrary.requestImage(with: album.assets.last) { image, _ in
                uiImage = image
            }
        }
    }
}

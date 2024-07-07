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
                                AlbumCoverView(album: album)
                                    .frame(width: proxy.size.width / 2 - 30)
                            }
                        }
                    }
                    .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
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
            }
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle("앨범")
        }
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

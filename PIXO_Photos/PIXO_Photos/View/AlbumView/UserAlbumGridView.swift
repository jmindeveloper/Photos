//
//  UserAlbumGridView.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/8/24.
//

import SwiftUI

protocol AlbumGridViewModelProtocol: ObservableObject {
    var library: PhotoLibrary { get }
    var userAlbum: [Album] { get set }
}

struct UserAlbumGridView<VM: AlbumGridViewModelProtocol>: View {
    @EnvironmentObject var viewModel: VM
    @State var albums: [Album]
    @State var columnCount: Int = 2
    @State var spacingWidth: CGFloat = 20
    
    /// true일시 사진보기 네비게이션 이동
    var isNavigate: Bool = true
    /// isNavigatie == true면 동작 안함
    var tapGestureAction: ((Album) -> Void)?
    
    var body: some View {
        ScrollView {
            let gridItem = Array(
                repeating: GridItem(.flexible(), spacing: spacingWidth),
                count: columnCount
            )
            
            LazyVGrid(columns: gridItem, spacing: spacingWidth) {
                ForEach(albums, id: \.self) { album in
                    if isNavigate {
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
                                .aspectRatio(0.9, contentMode: .fill)
                        }
                    } else {
                        AlbumCoverView(album: album)
                            .aspectRatio(0.9, contentMode: .fill)
                            .onTapGesture {
                                tapGestureAction?(album)
                            }
                    }
                    
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

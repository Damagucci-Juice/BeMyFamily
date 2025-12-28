//
//  AnimalDetailView.swift
//  BeMyFamily
//
//  Created by Gucci on 4/18/24.
//

import NukeUI
import SkeletonUI
import SwiftUI

struct AnimalDetailView: View {
    @Environment(\.displayScale) var displayScale
    @Environment(DIContainer.self) var diContainer: DIContainer
    @State private var loadedImage: Image?
    @State private var renderedImage: Image?
    let animal: AnimalEntity
    private var hasImage: Bool { loadedImage != nil ? false : true }
    
    var body: some View {
        ZStack {
            imageSection
            
            bottomGradientLayer
            
            briefInfoSection
        }
        .background(.black)
        .toolbar(.hidden, for: .tabBar)
    }
    private var bottomGradientLayer: some View {
        VStack {
            Spacer() // 위쪽은 비워둠
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, .black],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: UIConstants.Frame.screenHeight * 0.4)
        }
        .ignoresSafeArea() // 화면 끝까지 꽉 차게
        .allowsHitTesting(false) // 이 레이어가 터치 이벤트를 방해하지 않도록 설정
    }
    
    // 가로 세로 풍경에 대해서 대응
    @MainActor
    @ViewBuilder
    private var imageSection: some View {
        LazyImage(url: URL(string: animal.image1)) { state in
            if let image = state.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .onAppear { self.loadedImage = image }
            }
        }
        .onChange(of: loadedImage) { _, newValue in
            guard let newValue else { return }
            Task {
                self.renderedImage = render(
                    object: animal,
                    img: newValue,
                    displayScale: displayScale
                )
            }
        }
    }
    
    @ViewBuilder
    private var briefInfoSection: some View {
        VStack {
            Spacer()
            
            VStack {
                HStack {
                    Image(animal.kind.image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: 35, maxHeight: 35)
                        .aspectRatio(1, contentMode: .fill)
                        .clipShape(Circle())
                    
                    Text(animal.kind.name)
                        .foregroundStyle(.white)
                        .font(.animalName).bold()
                    
                    Spacer()
                }
                
                HStack {
                    Text(animal.specialMark)
                        .font(.animalName)
                        .foregroundStyle(.white)
                    Spacer()
                }
                
                actionButtons
            }
        }
        .padding(.horizontal)
    }
    
    // TODO: - CardNewsView와 중복되는데 해결
    @ViewBuilder
    private func detailRow(label: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(.noticeBody)
            Text(value)
                .font(.noticeBody)
            Spacer()
        }
        .foregroundStyle(.white)
    }
    
    @ViewBuilder
    private var actionButtons: some View {
        HStack {
            Spacer()
            
            if let favoriteVM = diContainer.resolveFactory(
                FavoriteButtonViewModel.self, parameter: animal
            ) {
                WhiteFavoriteButtonView(viewModel: favoriteVM)
                    .padding(.trailing, 16)
            }
            
            WhiteShareButton(renderedImage: $renderedImage, hasImage: hasImage)
        }
        .padding(.vertical)
    }
}

extension AnimalDetailView: @MainActor Sharable { }

#Preview {
    let animals = ModelData().animals.items
    
    NavigationView {
        AnimalDetailView(animal: Mapper.animalDto2Entity(animals[0]))
    }
}

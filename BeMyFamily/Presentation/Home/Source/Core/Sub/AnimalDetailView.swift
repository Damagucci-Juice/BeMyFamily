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

    // MARK: - 줌 관련 상태 프로퍼티
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var isZooming: Bool = false

    let animal: AnimalEntity
    private var hasImage: Bool { loadedImage != nil ? false : true }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            imageSection
                .scaleEffect(scale) // 이미지 확대 적용
                .gesture(magnificationGesture) // 제스처 연결

            // MARK: - 줌 상태가 아닐 때만 노출
            if !isZooming {
                bottomGradientLayer
                    .transition(.opacity.animation(.easeInOut)) // 부드러운 전환 효과

                briefInfoSection
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .toolbar(isZooming ? .hidden : .visible, for: .navigationBar)
    }

    // MARK: - Magnification Gesture 구현
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / lastScale
                lastScale = value
                let newScale = scale * delta

                scale = max(1.0, newScale)

                if scale > 1.01 {
                    withAnimation(.spring()) {
                        isZooming = true
                    }
                }
            }
            .onEnded { _ in
                lastScale = 1.0
                // 만약 사용자가 확대를 거의 다 풀었을 경우 원래대로 복구
                if scale <= 1.05 {
                    withAnimation(.spring()) {
                        scale = 1.0
                        isZooming = false
                    }
                }
            }
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

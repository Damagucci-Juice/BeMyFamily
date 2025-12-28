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

    // MARK: - 줌 및 이동 관련 상태 프로퍼티
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero        // 현재 이동 위치
    @State private var lastOffset: CGSize = .zero    // 직전 이동 위치
    @State private var isZooming: Bool = false
    @GestureState private var dragOffset: CGSize = .zero

    let animal: AnimalEntity
    private var hasImage: Bool { loadedImage != nil ? false : true }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            imageSection
                .offset(x: offset.width + dragOffset.width, y: offset.height + dragOffset.height)
                .scaleEffect(scale)
                // MARK: 렌더링 최적화 - 복잡한 뷰 계층을 하나의 비트맵으로 렌더링하여 성능을 끌어올립니다.
                .drawingGroup()
                // 개별 제스처 대신 결합된 제스처 하나만 사용
                .gesture(combinedGesture)

            if !isZooming {
                bottomGradientLayer
                    .transition(.opacity.animation(.easeInOut))
                briefInfoSection
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .toolbar(isZooming ? .hidden : .visible, for: .navigationBar)
    }

    // 중복 로직 분리
    private func handleZoomEnded() {
        if scale <= 1.05 {
            withAnimation(.spring()) {
                scale = 1.0
                offset = .zero
                isZooming = false
            }
        }
    }

    private var combinedGesture: some Gesture {
        // 줌과 드래그를 동시에 인식하도록 결합
        MagnificationGesture()
            .onChanged { value in
                let delta = value / lastScale
                lastScale = value
                scale = max(1.0, scale * delta)
                if scale > 1.01 { isZooming = true }
            }
            .onEnded { _ in
                lastScale = 1.0
                handleZoomEnded()
            }
        .simultaneously(with: DragGesture(minimumDistance: 0) // 반응성 향상을 위해 거리 0 설정
            .updating($dragOffset) { value, state, _ in
                guard isZooming else { return }
                state = value.translation
            }
            .onEnded { value in
                guard isZooming else { return }
                offset.width += value.translation.width
                offset.height += value.translation.height
            })
    }

    // MARK: - 최적화된 드래그 제스처
    private var dragGesture: some Gesture {
        DragGesture()
        // updating을 사용하면 시스템이 하드웨어 가속을 이용해 실시간 위치를 뷰에 직접 전달합니다.
            .updating($dragOffset) { value, state, _ in
                guard isZooming else { return }
                state = value.translation
            }
            .onEnded { value in
                guard isZooming else { return }
                // 드래그가 끝나면 최종 위치를 누적 저장합니다.
                offset.width += value.translation.width
                offset.height += value.translation.height
            }
    }

    // MARK: - 더블 탭 제스처 (초기화 로직 보강)
    private var doubleTapGesture: some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    if scale > 1.0 {
                        scale = 1.0
                        offset = .zero // 드래그 위치 초기화
                        isZooming = false
                    } else {
                        scale = 3.0
                        isZooming = true
                    }
                }
            }
    }

    // 핀치 줌 제스처 (기존 코드 보강)
    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / lastScale
                lastScale = value
                scale = max(1.0, scale * delta)

                if scale > 1.01 {
                    isZooming = true
                }
            }
            .onEnded { _ in
                lastScale = 1.0
                if scale <= 1.05 {
                    withAnimation(.spring()) {
                        scale = 1.0
                        offset = .zero
                        lastOffset = .zero
                        isZooming = false
                    }
                }
            }
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

    @MainActor
    @ViewBuilder
    private var imageSection: some View {
        LazyImage(url: URL(string: animal.image1)) { state in
            if let image = state.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
                    .offset(x: offset.width + dragOffset.width, y: offset.height + dragOffset.height)
                    .scaleEffect(scale)
                    .drawingGroup() // 성능 최적화
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

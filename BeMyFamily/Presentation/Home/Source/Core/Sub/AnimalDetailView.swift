//
//  AnimalDetailView.swift
//  BeMyFamily
//
//  Created by Gucci on 4/18/24.
//
import NukeUI
import SwiftUI

struct AnimalDetailView: View {
    @Environment(\.displayScale) var displayScale
    @Environment(DIContainer.self) var diContainer: DIContainer

    @State private var loadedImage: Image?
    @State private var renderedImage: Image?

    // MARK: - Zoom & Pan States
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var isZooming: Bool = false
    @GestureState private var dragOffset: CGSize = .zero
    @State private var imageSize: CGSize = .zero
    @State private var isDetailPresented = false

    let animal: AnimalEntity
    private var hasImage: Bool { loadedImage != nil }

    // MARK: - Constants
    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 3.0
    private let zoomThreshold: CGFloat = 1.01
    private let springAnim = Animation.spring(response: 0.4, dampingFraction: 0.8)

    var body: some View {
        ZStack {
            backgroundLayer

            GeometryReader { proxy in
                let topInset = proxy.safeAreaInsets.top
                let screenHeight = proxy.size.height
                let sheetTopEdge = screenHeight * 0.25
                let availableHeight = sheetTopEdge - topInset

                VStack(spacing: 0) {
                    // 1. 시트가 열렸을 때만 네비게이션 바 높이만큼 투명한 벽을 세웁니다.
                    if isDetailPresented {
                        Color.clear.frame(height: topInset)
                    }

                    // 2. 남은 가용 영역(availableHeight) 내에 이미지를 가둡니다.
                    imageSection
                        .scaleEffect(isDetailPresented ?
                                     calculateFitScale(availableHeight: availableHeight, screenSize: proxy.size) :
                                        scale)
                    // 시트가 열리면 중앙 정렬이 아닌 상단 정렬 느낌을 주기 위해 offset 미세 조정
                        .offset(y: isDetailPresented ? 0 : 0)
                        .frame(maxWidth: .infinity, maxHeight: isDetailPresented ? availableHeight : .infinity)

                    if isDetailPresented {
                        Spacer(minLength: 0) // 아래쪽(시트 위) 여백
                    }
                }
                .animation(springAnim, value: isDetailPresented)
            }
            .ignoresSafeArea()

            if !isZooming && !isDetailPresented {
                bottomGradientLayer
                briefInfoSection
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .onTapGesture {
            if isDetailPresented {
                withAnimation(.spring()) {
                    isDetailPresented = false
                }
            }
        }
        .background(Color.black)
        .highPriorityGesture(isZooming ? nil : swipeGesture)
        .toolbar(.hidden, for: .tabBar)
        .toolbar(isZooming || isDetailPresented ? .hidden : .visible, for: .navigationBar)
        .sheet(isPresented: $isDetailPresented) {
            VStack {
                Text(animal.kind.name)
                    .font(.animalName)
                    .bold()
                    .foregroundStyle(.primary)
                Spacer()
            }
            .padding()
            // MARK: - 높이 조절 핵심 코드
            .presentationDetents([
                .fraction(0.75),
                .large
            ])
            .presentationBackground(.ultraThinMaterial)
            .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.75)))
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Subviews
private extension AnimalDetailView {
    var backgroundLayer: some View {
        Color.black.ignoresSafeArea()
    }

    @MainActor
    func imageContentView(screenSize: CGSize) -> some View {
        imageSection
            .scaleEffect(scale)
            .offset(x: offset.width + dragOffset.width, y: offset.height + dragOffset.height)
            .frame(width: screenSize.width, height: screenSize.height)
            .onTapGesture {
                if isDetailPresented {
                    withAnimation(.spring()) {
                        isDetailPresented = false
                    }
                }
            }
            .gesture(doubleTapGesture(screenSize: screenSize))
            .gesture(combinedGesture(screenSize: screenSize))
            .drawingGroup()
    }

    var overlayInformation: some View {
        ZStack(alignment: .bottom) {
            bottomGradientLayer
            briefInfoSection
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    @MainActor
    var imageSection: some View {
        LazyImage(url: URL(string: animal.image1)) { state in
            if let image = state.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .onAppear {
                        self.loadedImage = image
                        if let uiImage = try? state.result?.get().image {
                            self.imageSize = uiImage.size
                        }
                    }
            } else {
                Rectangle().fill(Color.black)
            }
        }
    }

    var bottomGradientLayer: some View {
        VStack {
            Spacer()
            Rectangle()
                .fill(LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom))
                .frame(height: UIConstants.Frame.screenHeight * 0.5)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    var briefInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Spacer()

            HStack(spacing: 10) {
                kindImage
                Text(animal.kind.name)
                    .foregroundStyle(.white)
                    .font(.animalName).bold()
                Spacer()
            }

            Text(animal.specialMark)
                .font(.animalName)
                .foregroundStyle(.white)

            actionButtons
        }
        .padding(.horizontal)
    }

    var kindImage: some View {
        Image(animal.kind.image)
            .resizable()
            .scaledToFill()
            .frame(width: 35, height: 35)
            .clipShape(Circle())
    }

    var actionButtons: some View {
        HStack {
            Spacer()
            if let favoriteVM = diContainer.resolveFactory(FavoriteButtonViewModel.self, parameter: animal) {
                WhiteFavoriteButtonView(viewModel: favoriteVM)
                    .padding(.trailing, 16)
            }
            WhiteShareButton(renderedImage: $renderedImage, hasImage: hasImage)
        }
        .padding(.vertical)
    }
}

// MARK: - Gestures & Logic
private extension AnimalDetailView {
    var swipeGesture: some Gesture {
        DragGesture()
            .onEnded { value in
                // 위로 스와이프 감지 (세로 이동 거리가 -50 미만일 때)
                if value.translation.height < -50 {
                    withAnimation(.spring()) {
                        isDetailPresented = true
                    }
                }
            }
    }

    func combinedGesture(screenSize: CGSize) -> some Gesture {
        let magnification = MagnificationGesture()
            .onChanged { value in
                let delta = value / lastScale
                lastScale = value
                scale = max(minScale, scale * delta)
                if scale > zoomThreshold { isZooming = true }
            }
            .onEnded { _ in
                lastScale = 1.0
                withAnimation(springAnim) {
                    validateBoundsAndReset(screenSize: screenSize)
                }
            }

        let drag = DragGesture(minimumDistance: 0)
            .updating($dragOffset) { value, state, _ in
                if isZooming { state = value.translation }
            }
            .onEnded { value in
                guard !isDetailPresented && isZooming else { return }
                offset.width += value.translation.width
                offset.height += value.translation.height
                withAnimation(springAnim) {
                    updateOffsetInRange(screenSize: screenSize)
                }
            }

        return magnification.simultaneously(with: drag)
    }

    func doubleTapGesture(screenSize: CGSize) -> some Gesture {
        SpatialTapGesture(count: 2)
            .onEnded { value in
                withAnimation(springAnim) {
                    guard !isDetailPresented else { return }
                    if scale > 1.1 {
                        resetZoom()
                    } else {
                        scale = maxScale
                        let targetX = (screenSize.width / 2 - value.location.x) * 2
                        let targetY = (screenSize.height / 2 - value.location.y) * 2
                        offset = CGSize(width: targetX, height: targetY)
                        updateOffsetInRange(screenSize: screenSize)
                        isZooming = true
                    }
                }
            }
    }

    func validateBoundsAndReset(screenSize: CGSize) {
        if scale <= 1.05 {
            resetZoom()
        } else {
            updateOffsetInRange(screenSize: screenSize)
        }
    }

    func resetZoom() {
        scale = 1.0
        offset = .zero
        lastOffset = .zero
        isZooming = false
    }

    func updateOffsetInRange(screenSize: CGSize) {
        guard imageSize.width > 0 && imageSize.height > 0 else { return }

        let zoomedWidth = screenSize.width * scale
        let aspectRatio = imageSize.width / imageSize.height
        let zoomedHeight = (screenSize.width / aspectRatio) * scale

        let maxW = max(0, (zoomedWidth - screenSize.width) / 2)
        let maxH = max(0, (zoomedHeight - screenSize.height) / 2)

        offset.width = min(max(offset.width, -maxW), maxW)
        offset.height = min(max(offset.height, -maxH), maxH)
    }
}

extension AnimalDetailView: @MainActor Sharable { }

private extension AnimalDetailView {
    func calculateFitScale(availableHeight: CGFloat, screenSize: CGSize) -> CGFloat {
        guard imageSize.width > 0 && imageSize.height > 0 else { return 0.5 }
        let aspectRatio = imageSize.width / imageSize.height
        let currentImageHeight = screenSize.width / aspectRatio

        // 0.95 정도가 적당히 네비게이션 바와 시트 사이에 꽉 차 보이게 합니다.
        let scaleTarget = (availableHeight / currentImageHeight) * 0.95
        return min(scaleTarget, 0.7)
    }
}

/**
 private extension AnimalDetailView {
 func calculateFitScale(availableHeight: CGFloat, screenSize: CGSize) -> CGFloat {
 guard imageSize.width > 0 && imageSize.height > 0 else { return 0.5 }

 let aspectRatio = imageSize.width / imageSize.height
 let currentImageHeight = screenSize.width / aspectRatio

 // 0.95 -> 0.90 으로 변경하여 상하 여백을 조금 더 확보합니다.
 let scaleTarget = (availableHeight / currentImageHeight) * 0.90

 return min(scaleTarget, 0.7)
 }
 }
 */

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
                imageContentView(screenSize: proxy.size)
            }
            .ignoresSafeArea()

            if !isZooming {

                bottomGradientLayer

                briefInfoSection
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .background(Color.black)
        .toolbar(.hidden, for: .tabBar)
        .toolbar(isZooming ? .hidden : .visible, for: .navigationBar)
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
                if isZooming {
                    offset.width += value.translation.width
                    offset.height += value.translation.height
                    withAnimation(springAnim) {
                        updateOffsetInRange(screenSize: screenSize)
                    }
                }
            }

        return magnification.simultaneously(with: drag)
    }

    func doubleTapGesture(screenSize: CGSize) -> some Gesture {
        SpatialTapGesture(count: 2)
            .onEnded { value in
                withAnimation(springAnim) {
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

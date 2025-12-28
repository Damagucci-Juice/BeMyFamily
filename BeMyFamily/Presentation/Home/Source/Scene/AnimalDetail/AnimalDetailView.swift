//
//  AnimalDetailView.swift
//  BeMyFamily
//
//  Created by Gucci on 4/18/24.
//

import NukeUI
import SwiftUI

struct AnimalDetailView: View {
    // MARK: - Environment
    @Environment(\.displayScale) var displayScale
    @Environment(DIContainer.self) var diContainer: DIContainer

    // MARK: - State
    @State private var viewModel = AnimalDetailViewModel()
    @State private var loadedImage: Image?
    @State private var renderedImage: Image?

    init(_ animal: AnimalEntity) {
        self.animal = animal
        self._viewModel = State(wrappedValue: DIContainer.shared.resolveFactory(AnimalDetailViewModel.self)!)
    }

    // MARK: - Properties
    let animal: AnimalEntity

    private var hasImage: Bool { loadedImage != nil }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            GeometryReader { proxy in
                ImageContentView(
                    animal: animal,
                    viewModel: viewModel,
                    loadedImage: $loadedImage,
                    screenSize: proxy.size
                )
            }
            .ignoresSafeArea()

            if !viewModel.isZooming && !viewModel.isDetailPresented {
                BottomOverlayView(
                    animal: animal,
                    diContainer: diContainer,
                    renderedImage: $renderedImage,
                    hasImage: hasImage
                )
            }
        }
        .highPriorityGesture(viewModel.isZooming ? nil : viewModel.swipeGesture)
        .toolbar(.hidden, for: .tabBar)
        .toolbar(viewModel.shouldHideNavigationBar ? .hidden : .visible, for: .navigationBar)
        .sheet(isPresented: $viewModel.isDetailPresented) {
            AnimalDetailSheet(animal: animal)
                .interactiveDismissDisabled(false)
        }
    }
}

// MARK: - Image Content View
private struct ImageContentView: View {
    let animal: AnimalEntity
    @Bindable var viewModel: AnimalDetailViewModel
    @Binding var loadedImage: Image?
    let screenSize: CGSize

    @GestureState private var dragOffset: CGSize = .zero

    private var layout: LayoutMetrics {
        LayoutMetrics(screenSize: screenSize)
    }

    var body: some View {
        VStack(spacing: 0) {
            Color.clear
                .frame(height: layout.navigationBarHeight)

            AnimalImageView(
                animal: animal,
                loadedImage: $loadedImage,
                imageSize: $viewModel.imageSize
            )
            .scaleEffect(imageScale)
            .offset(imageOffset)
            .frame(
                maxWidth: .infinity,
                maxHeight: imageMaxHeight
            )
            .clipped()
            .contentShape(Rectangle()) // 이미지 영역 전체를 터치 가능하게
            .onTapGesture {
                // 시트가 올라와 있으면 시트 닫기
                if viewModel.isDetailPresented {
                    withAnimation(.spring()) {
                        viewModel.isDetailPresented = false
                    }
                }
            }
            .gesture(viewModel.createDoubleTapGesture(screenSize: screenSize))
            .gesture(combinedGesture)

            if viewModel.isDetailPresented {
                Spacer(minLength: 0)
                    .contentShape(Rectangle()) // Spacer도 터치 가능하게
                    .onTapGesture {
                        withAnimation(.spring()) {
                            viewModel.isDetailPresented = false
                        }
                    }
            }
        }
        .animation(viewModel.springAnimation, value: viewModel.isDetailPresented)
    }

    private var imageScale: CGFloat {
        viewModel.isDetailPresented
            ? viewModel.calculateFitScale(availableHeight: layout.availableHeight, screenSize: screenSize)
            : viewModel.scale
    }

    private var imageOffset: CGSize {
        guard viewModel.isZooming else { return .zero }
        return CGSize(
            width: viewModel.offset.width + dragOffset.width,
            height: viewModel.offset.height + dragOffset.height
        )
    }

    private var imageMaxHeight: CGFloat {
        viewModel.isDetailPresented
            ? layout.availableHeight
            : screenSize.height - layout.navigationBarHeight
    }

    private var combinedGesture: some Gesture {
        let magnification = viewModel.createMagnificationGesture(screenSize: screenSize)

        let drag = DragGesture(minimumDistance: 0)
            .updating($dragOffset) { value, state, _ in
                state = viewModel.handleDragChanged(value: value)
            }
            .onEnded { value in
                viewModel.handleDragEnded(value: value, screenSize: screenSize)
            }

        return magnification.simultaneously(with: drag)
    }
}

// MARK: - Layout Metrics
private struct LayoutMetrics {
    let screenSize: CGSize
    let navigationBarHeight = UIConstants.Frame.naviBarHeight

    var sheetTopEdge: CGFloat {
        screenSize.height * 0.25
    }

    var availableHeight: CGFloat {
        sheetTopEdge + navigationBarHeight
    }
}

// MARK: - Animal Image View
private struct AnimalImageView: View {
    let animal: AnimalEntity
    @Binding var loadedImage: Image?
    @Binding var imageSize: CGSize

    var body: some View {
        LazyImage(url: URL(string: animal.image1)) { state in
            if let image = state.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        width: UIScreen.main.bounds.width,
                        height: UIScreen.main.bounds.height
                    )
                    .onAppear {
                        handleImageLoad(state: state, image: image)
                    }
            } else {
                Rectangle().fill(Color.black)
            }
        }
    }

    private func handleImageLoad(state: LazyImageState, image: Image) {
        loadedImage = image
        if let uiImage = try? state.result?.get().image {
            imageSize = uiImage.size
        }
    }
}

// MARK: - Bottom Overlay View
private struct BottomOverlayView: View {
    let animal: AnimalEntity
    let diContainer: DIContainer
    @Binding var renderedImage: Image?
    let hasImage: Bool

    var body: some View {
        VStack {
            Spacer()

            ZStack(alignment: .bottom) {
                gradientLayer
                infoSection
            }
        }
        .ignoresSafeArea()
    }

    private var gradientLayer: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.clear, .black],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(height: UIConstants.Frame.screenHeight * 0.5)
            .allowsHitTesting(false)
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                kindImage
                Text(animal.kind.name)
                    .font(.animalName)
                    .bold()
                    .foregroundStyle(.white)
                Spacer()
            }

            Text(animal.specialMark)
                .font(.animalName)
                .foregroundStyle(.white)

            actionButtons
        }
        .padding(.horizontal)
    }

    private var kindImage: some View {
        Image(animal.kind.image)
            .resizable()
            .scaledToFill()
            .frame(width: 35, height: 35)
            .clipShape(Circle())
    }

    private var actionButtons: some View {
        HStack {
            Spacer()
            if let favoriteVM = diContainer.resolveFactory(
                FavoriteButtonViewModel.self,
                parameter: animal
            ) {
                WhiteFavoriteButtonView(viewModel: favoriteVM)
                    .padding(.trailing, 16)
            }
            WhiteShareButton(renderedImage: $renderedImage, hasImage: hasImage)
        }
        .padding(.vertical)
    }
}

// MARK: - Animal Detail Sheet
private struct AnimalDetailSheet: View {
    let animal: AnimalEntity

    var body: some View {
        VStack {
            Text(animal.kind.name)
                .font(.animalName)
                .bold()
                .foregroundStyle(.primary)
            Spacer()
        }
        .padding()
        .presentationDetents([.fraction(0.75), .large])
        .presentationBackground(.ultraThinMaterial)
        .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.75)))
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Sharable Conformance
extension AnimalDetailView: @MainActor Sharable { }

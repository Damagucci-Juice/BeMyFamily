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

    // MARK: - 줌 및 이동 관련 상태 프로퍼티
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero        // 현재 이동 위치
    @State private var lastOffset: CGSize = .zero    // 직전 이동 위치
    @State private var isZooming: Bool = false
    @GestureState private var dragOffset: CGSize = .zero
    @State private var imageSize: CGSize = .zero // 실제 이미지의 렌더링 사이즈 저장

    let animal: AnimalEntity
    private var hasImage: Bool { loadedImage != nil ? false : true }

    var body: some View {
        ZStack {
            // 1. 배경을 검정으로 꽉 채워 전체 캔버스 확보
            Color.black.ignoresSafeArea()

            GeometryReader { proxy in
                imageSection
                    // 1. 시각적 효과 먼저 적용
                    .scaleEffect(scale)
                    .offset(x: offset.width + dragOffset.width, y: offset.height + dragOffset.height)
                    // 2. 전체 프레임 잡기
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    // 3. 제스처를 각각 등록 (순서대로 인식됨)
                    .gesture(doubleTapGesture(screenSize: proxy.size)) // 더블 탭
                    .gesture(combinedGesture(screenSize: proxy.size))  // 핀치 & 드래그
                    .drawingGroup()
            }
            .ignoresSafeArea()

            if !isZooming {
                bottomGradientLayer
                briefInfoSection
            }
        }
        .background(Color.black)
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

    private func combinedGesture(screenSize: CGSize) -> some Gesture {
        // 1. 확대/축소 제스처
        let magnification = MagnificationGesture()
            .onChanged { value in
                let delta = value / lastScale
                lastScale = value
                scale = max(1.0, scale * delta)
                if scale > 1.01 { isZooming = true }
            }
            .onEnded { _ in
                lastScale = 1.0
                withAnimation(.spring()) {
                    if scale <= 1.05 {
                        resetZoom() // 원래 크기로 복구
                    } else {
                        updateOffsetInRange(screenSize: screenSize) // 경계 안으로 튕기기
                    }
                }
            }

        // 2. 드래그 이동 제스처
        let drag = DragGesture(minimumDistance: 0)
            .updating($dragOffset) { value, state, _ in
                if isZooming { state = value.translation }
            }
            .onEnded { value in
                if isZooming {
                    offset.width += value.translation.width
                    offset.height += value.translation.height
                    withAnimation(.spring()) {
                        updateOffsetInRange(screenSize: screenSize)
                    }
                }
            }

        return magnification.simultaneously(with: drag)
    }

    // 초기화 헬퍼 함수
    private func resetZoom() {
        scale = 1.0
        offset = .zero
        isZooming = false
    }

    // MARK: - 경계값 계산 및 오프셋 보정 로직
    private func updateOffsetInRange(screenSize: CGSize) {
        // 이미지가 .fit 모드일 때 화면 내에서 차지하는 실제 영역 계산
        // (화면 너비는 꽉 차지만 높이는 이미지 비율에 따라 남을 수 있음)
        let zoomedWidth = screenSize.width * scale
        let zoomedHeight = (screenSize.width / (imageSize.width / imageSize.height)) * scale

        // 가로 경계값: (확대된 너비 - 화면 너비) / 2
        let maxW = max(0, (zoomedWidth - screenSize.width) / 2)
        // 세로 경계값: (확대된 높이 - 화면 높이) / 2 (이미지가 화면보다 작으면 0)
        let maxH = max(0, (zoomedHeight - screenSize.height) / 2)

        offset.width = min(max(offset.width, -maxW), maxW)
        offset.height = min(max(offset.height, -maxH), maxH)
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

    private func doubleTapGesture(screenSize: CGSize) -> some Gesture {
        SpatialTapGesture(count: 2)
            .onEnded { value in
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    if scale > 1.1 {
                        // 이미 확대되어 있다면 초기화
                        resetZoom()
                    } else {
                        // 1. 새로운 스케일 설정
                        scale = 3.0

                        // 2. 터치한 지점을 중앙으로 옮기기 위한 오프셋 계산
                        // 터치 지점(value.location)에서 화면 중앙(screenSize/2)을 뺀 거리의 '반대 방향'으로 이동
                        let targetX = (screenSize.width / 2 - value.location.x) * 2
                        let targetY = (screenSize.height / 2 - value.location.y) * 2

                        offset = CGSize(width: targetX, height: targetY)

                        // 3. 이동 후 경계값 밖으로 나가지 않게 보정
                        updateOffsetInRange(screenSize: screenSize)
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
                    .frame(width: UIScreen.main.bounds.width,
                           height: UIScreen.main.bounds.height)
                    .onAppear {
                        self.loadedImage = image
                        // 실제 이미지의 원본 사이즈를 추출하여 비율 계산에 활용
                        if let uiImage = try? state.result?.get().image {
                            self.imageSize = uiImage.size
                        }
                    }
            } else {
                Rectangle().fill(Color.black) // 로딩 중에도 검은 배경 유지
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

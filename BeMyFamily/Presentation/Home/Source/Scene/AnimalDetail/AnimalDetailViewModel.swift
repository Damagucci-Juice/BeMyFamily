//
//  AnimalDetailViewModel.swift
//  BeMyFamily
//
//  Created by Gucci on 12/28/25.
//
import Foundation
import Observation
import SwiftUI

// MARK: - ViewModel
@Observable
final class AnimalDetailViewModel {
    // MARK: - Zoom & Pan States
    var scale: CGFloat = 1.0
    var lastScale: CGFloat = 1.0
    var offset: CGSize = .zero
    var lastOffset: CGSize = .zero
    var isZooming: Bool = false
    var isDetailPresented = false
    var imageSize: CGSize = .zero

    // MARK: - Constants
    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 3.0
    private let zoomThreshold: CGFloat = 1.01
    let springAnimation = Animation.spring(response: 0.4, dampingFraction: 0.8)

    var shouldHideNavigationBar: Bool {
        isZooming || isDetailPresented
    }

    var isInitialLoad: Bool {
        !isZooming && !isDetailPresented
    }

    // MARK: - Swipe Gesture
    var swipeGesture: some Gesture {
        DragGesture()
            .onEnded { value in
                if value.translation.height < -50 {
                    withAnimation(.spring()) {
                        self.isDetailPresented = true
                    }
                }
            }
    }

    // MARK: - Actions
    func handleBackgroundTap() {
        if isDetailPresented {
            withAnimation(.spring()) {
                isDetailPresented = false
            }
        }
    }

    // MARK: - Zoom Gestures
    func createMagnificationGesture(screenSize: CGSize) -> some Gesture {
        MagnificationGesture()
            .onChanged { [weak self] value in
                guard let self = self else { return }
                let delta = value / self.lastScale
                self.lastScale = value
                self.scale = max(self.minScale, self.scale * delta)
                if self.scale > self.zoomThreshold {
                    self.isZooming = true
                }
            }
            .onEnded { [weak self] _ in
                guard let self = self else { return }
                self.lastScale = 1.0
                withAnimation(self.springAnimation) {
                    self.validateBoundsAndReset(screenSize: screenSize)
                }
            }
    }

    func handleDragChanged(value: DragGesture.Value) -> CGSize {
        guard isZooming else { return .zero }
        return value.translation
    }

    func handleDragEnded(value: DragGesture.Value, screenSize: CGSize) {
        guard !isDetailPresented && isZooming else { return }
        offset.width += value.translation.width
        offset.height += value.translation.height
        withAnimation(springAnimation) {
            self.updateOffsetInRange(screenSize: screenSize)
        }
    }

    func createDoubleTapGesture(screenSize: CGSize) -> some Gesture {
        SpatialTapGesture(count: 2)
            .onEnded { [weak self] value in
                guard let self = self else { return }
                withAnimation(self.springAnimation) {
                    guard !self.isDetailPresented else { return }
                    if self.scale > 1.1 {
                        self.resetZoom()
                    } else {
                        self.zoomToPoint(value.location, screenSize: screenSize)
                    }
                }
            }
    }

    // MARK: - Zoom Logic
    private func zoomToPoint(_ location: CGPoint, screenSize: CGSize) {
        scale = maxScale
        let targetX = (screenSize.width / 2 - location.x) * 2
        let targetY = (screenSize.height / 2 - location.y) * 2
        offset = CGSize(width: targetX, height: targetY)
        updateOffsetInRange(screenSize: screenSize)
        isZooming = true
    }

    private func validateBoundsAndReset(screenSize: CGSize) {
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

    private func updateOffsetInRange(screenSize: CGSize) {
        guard imageSize.width > 0 && imageSize.height > 0 else { return }

        let aspectRatio = imageSize.width / imageSize.height
        let zoomedWidth = screenSize.width * scale
        let zoomedHeight = (screenSize.width / aspectRatio) * scale

        let maxW = max(0, (zoomedWidth - screenSize.width) / 2)
        let maxH = max(0, (zoomedHeight - screenSize.height) / 2)

        offset.width = min(max(offset.width, -maxW), maxW)
        offset.height = min(max(offset.height, -maxH), maxH)
    }

    // MARK: - Scale Calculation
    func calculateFitScale(availableHeight: CGFloat, screenSize: CGSize) -> CGFloat {
        guard imageSize.width > 0 && imageSize.height > 0 else { return 0.5 }

        let aspectRatio = imageSize.width / imageSize.height
        let currentImageHeight = screenSize.width / aspectRatio
        let scaleTarget = (availableHeight / currentImageHeight) * 0.95

        return min(scaleTarget, 0.7)
    }
}

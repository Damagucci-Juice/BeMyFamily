import SwiftUI

struct AnimalDetailSheet: View {
    let animal: AnimalEntity

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                specialMarkSection
                basicInfoGridSection
                colorInfoSection
                locationAndDateSection
                healthInfoSection
                careCenterSection
                if canShowAdoptionInfo {
                    adoptionInfoSection
                }
                actionButtonsSection
            }
            .padding(.horizontal)
        }
        .presentationDetents([.fraction(0.75), .large])
        .presentationContentInteraction(.scrolls)
        .presentationDragIndicator(.visible)
        .presentationBackground(.ultraThinMaterial)
    }
}

// MARK: - Subviews
private extension AnimalDetailSheet {

    // 1. 헤더 (이미지, 이름, 상태)
    var headerSection: some View {
        HStack(spacing: 8) {
            Image(animal.kind.image)
                .resizable()
                .scaledToFill()
                .frame(width: 35, height: 35)
                .clipShape(Circle())

            Text(animal.kind.name)
                .font(.animalName).bold()
                .foregroundStyle(.primary)

            Text(animal.relativeNoticeDate)
                .font(.noticeDays)
                .foregroundStyle(.secondary)

            Spacer()

            Text(animal.processState.rawValue)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.1))
                .foregroundColor(.green)
                .clipShape(Capsule())
        }
        .padding(.top, 20)
    }

    // 2. 특징 텍스트
    var specialMarkSection: some View {
        Text(animal.specialMark)
            .font(.noticeBody)
            .foregroundColor(.primary)
            .lineSpacing(4)
    }

    // 3. 기본 정보 그리드
    var basicInfoGridSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            InfoCard(title: "나이", value: animal.age)
            InfoCard(title: "체중", value: animal.weight)
            InfoCard(title: "성별", value: animal.sexCd.text)
            InfoCard(title: "중성화", value: animal.neuterYn.text)
        }
    }

    // 4. 색상 정보
    var colorInfoSection: some View {
        InfoCard(title: "색상", value: animal.color)
            .frame(maxWidth: .infinity)
    }

    // 5. 위치 및 날짜
    var locationAndDateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            IconLabelRow(icon: "mappin.and.ellipse", text: "발견 장소", subText: animal.happenPlace)
            IconLabelRow(icon: "calendar", text: "공고 기간", subText: "\(animal.noticeStartDate) ~ \(animal.noticeEndDate)")
        }
        .padding(.horizontal, 4)
    }

    // 6. 건강 정보
    var healthInfoSection: some View {
        SectionView(title: "건강 정보", backgroundColor: Color.blue.opacity(0.05)) {
            VStack(alignment: .leading, spacing: 8) {
                Text("상태: \(animal.healthStatus ?? "양호")")
                Text("예방접종: \(animal.vaccinationStatus ?? "정보 없음")")
            }
            .font(.system(size: 15))
        }
    }

    // 7. 보호센터 정보
    var careCenterSection: some View {
        SectionView(title: "보호센터 정보") {
            VStack(alignment: .leading, spacing: 6) {
                Text("시설명: \(animal.careName)")
                Text("연락처: \(animal.careTel)")
                Text("주소: \(animal.careAddress)")
            }
            .font(.system(size: 14))
            .foregroundColor(.secondary)
        }
    }

    // 8. 입양 안내 정보
    var adoptionInfoSection: some View {
        SectionView(title: animal.adptnTitle ?? "입양 가능", backgroundColor: Color.purple.opacity(0.05)) {
            VStack(alignment: .leading, spacing: 8) {
                Text(animal.adptnTxt ?? "건강하고 활발한 \(animal.kind.upKind.adoptionGuide)입니다. \n사랑으로 키워주실 분을 기다립니다.")
                if let condition = animal.adptnConditionLimitTxt {
                    Text("조건: \(condition)")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
            .font(.system(size: 15))
        }
    }

    var canShowAdoptionInfo: Bool {
        animal.processState == .inProtect
    }
}

// MARK: - Reusable UI Components
private extension AnimalDetailSheet {
    func secondaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
        }
        .foregroundColor(.black)
    }

    func primaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(white: 0.2))
                .cornerRadius(12)
        }
        .foregroundColor(.white)
    }
}

private extension AnimalDetailSheet {

    var actionButtonsSection: some View {
        HStack(spacing: 12) {
            secondaryButton(title: "공유하기") {
                // 공유 액션
                shareAnimal()
            }

            if canShowAdoptionInfo {
                Menu {
                    Button(action: { makePhoneCall(phoneNumber: animal.careTel) }) {
                        Label("전화 문의하기", systemImage: "phone")
                    }

                    Button(action: { openMapApp(type: .naver, address: animal.careAddress) }) {
                        Label("네이버 지도로 보기", systemImage: "map")
                    }

                    Button(action: { openMapApp(type: .kakao, address: animal.careAddress) }) {
                        Label("카카오맵으로 보기", systemImage: "mappin.and.ellipse")
                    }
                } label: {
                    // 기존 primaryButton 스타일 유지
                    Text("입양 문의")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(white: 0.2))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                }
            }

        }
        .padding(.top, 10)
        .padding(.bottom, 30)
    }

    // MARK: - Helper Methods

    // 전화 걸기
    func makePhoneCall(phoneNumber: String) {
        let cleanNumber = phoneNumber.filter("0123456789".contains)
        if let url = URL(string: "tel://\(cleanNumber)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    enum MapType { case naver, kakao }

    // 지도 앱 열기
    func openMapApp(type: MapType, address: String) {
        let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        var appUrlString = ""
        var webUrlString = ""

        switch type {
        case .naver:
            appUrlString = "nmap://search?query=\(encodedAddress)&appname=BeMyFamily"
            webUrlString = "https://m.map.naver.com/search2/search.naver?query=\(encodedAddress)"
        case .kakao:
            appUrlString = "kakaomap://search?q=\(encodedAddress)"
            webUrlString = "https://map.kakao.com/link/search/\(encodedAddress)"
        }

        if let appUrl = URL(string: appUrlString), UIApplication.shared.canOpenURL(appUrl) {
            // 앱이 있으면 앱으로 실행
            UIApplication.shared.open(appUrl)
        } else if let webUrl = URL(string: webUrlString) {
            // 앱이 없으면 사파리 브라우저로 실행
            UIApplication.shared.open(webUrl)
        }
    }

    func shareAnimal() {
        let baseURL = "https://damagucci-juice.github.io/BeMyFamily"

        let universalLink = "\(baseURL)/detail?id=\(animal.desertionNo)"

        guard let url = URL(string: universalLink) else { return }

        let message = """
            [BeMyFamily] 가족을 기다리는 유기동물 친구가 있어요!
            
            🐶 종류: \(animal.kind.name)
            🆔 공고번호: \(animal.noticeNumber)
            📍 발견장소: \(animal.happenPlace)
            
            이 아이의 자세한 정보를 확인해보세요:
            \(universalLink)
            """

        let activityVC = UIActivityViewController(activityItems: [message, url], applicationActivities: nil)

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else { return }

        var topVC = rootVC
        while let presentedVC = topVC.presentedViewController {
            topVC = presentedVC
        }

        // iPad 크래시 방지
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = topVC.view
            popover.sourceRect = CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        topVC.present(activityVC, animated: true)
    }
}

private struct InfoCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.gray)
            Text(value)
                .font(.noticeBody)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

private struct SectionView<Content: View>: View {
    let title: String
    var icon: String?
    var backgroundColor: Color = Color.gray.opacity(0.03)
    let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(.system(size: 16, weight: .bold))
            }
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(backgroundColor)
        .cornerRadius(16)
    }
}

private struct IconLabelRow: View {
    let icon: String
    let text: String
    let subText: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 4) {
                Text(text)
                    .font(.system(size: 14, weight: .medium))
                Text(subText)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
    }
}


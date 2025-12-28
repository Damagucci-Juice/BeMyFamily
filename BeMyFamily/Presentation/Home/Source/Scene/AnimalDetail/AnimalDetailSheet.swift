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
                adoptionInfoSection
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

            Spacer()

            Text(animal.processState)
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
                Text(animal.adptnTxt ?? "건강하고 활발한 강아지입니다. \n사랑으로 키워주실 분을 기다립니다.")
                if let condition = animal.adptnConditionLimitTxt {
                    Text("조건: \(condition)")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
            .font(.system(size: 15))
        }
    }

    // 9. 하단 버튼 액션
    var actionButtonsSection: some View {
        HStack(spacing: 12) {
            secondaryButton(title: "공유하기") {
                // 공유 액션
            }
            primaryButton(title: "입양 문의") {
                // 입양 문의 액션
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 30)
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


private struct InfoCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 18, weight: .bold))
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

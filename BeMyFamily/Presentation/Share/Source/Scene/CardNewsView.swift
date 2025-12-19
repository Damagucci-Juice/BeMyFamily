//
//  CardNewsView.swift
//  BeMyFamily
//
//  Created by Gucci on 4/26/24.
//

import SwiftUI

struct CardNewsView: View {
    let image: Image
    let animal: Animal

    var body: some View {

        VStack {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIConstants.Frame.screenWidthWithPadding,
                       height: UIConstants.Frame.feedImageHeight)
                .clipShape(RoundedRectangle(cornerRadius: UIConstants.Radius.mainImagePlaceholder))

            detailSection
                .padding()
        }
    }

    @ViewBuilder
    private var detailSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                detailRow(label: "특이사항:", value: animal.specialMark)
                detailRow(label: "접수일:", value: animal.happenDt)
                detailRow(label: "발견장소:", value: animal.happenPlace)
                detailRow(label: "품종:", value: animal.kindCD)
                detailRow(label: "색:", value: animal.colorCD)
                detailRow(label: "나이:", value: animal.age)
                detailRow(label: "무게:", value: animal.weight)
                detailRow(label: "처리 상태:", value: animal.processState)
                detailRow(label: "성별:", value: animal.sexCD.text)
                detailRow(label: "중성화 여부:", value: animal.neuterYn.text)
                detailRow(label: "보호소 이름:", value: animal.careNm)
                detailRow(label: "보호소 연락처:", value: animal.careTel)
            }
        }
    }

    @ViewBuilder
    private func detailRow(label: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .bold()
            Text(value)
            Spacer()
        }
    }
}

#Preview {
    let animals = ModelData().animals.items
    return CardNewsView(image: Image(systemName: "photo"), animal: animals[0])
}

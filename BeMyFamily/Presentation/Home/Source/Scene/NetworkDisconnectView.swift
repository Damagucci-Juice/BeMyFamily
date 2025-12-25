//
//  NetworkDisconnectView.swift
//  BeMyFamily
//
//  Created by Gucci on 12/25/25.
//

import SwiftUI

struct NetworkDisconnectView: View {
    var body: some View {
        ContentUnavailableView("네트워크 연결이 없어요.", systemImage: "wifi.slash")
            .padding(.top, 100)
    }
}

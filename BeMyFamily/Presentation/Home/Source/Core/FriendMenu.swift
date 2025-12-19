//
//  FriendMenu.swift
//  BeMyFamily
//
//  Created by Gucci on 4/19/24.
//

import Foundation

enum FriendMenu: CaseIterable {
    case feed, favorite, filter

    var title: String {
        switch self {
        case .feed:
            return UIConstants.App.feed
        case .favorite:
            return UIConstants.App.favorite
        case .filter:
            return UIConstants.App.filter
        }
    }

    var image: String {
        switch self {
        case .feed, .filter:
            return UIConstants.App.feedIcon
        case .favorite:
            return UIConstants.App.favoriteIcon
        }
    }
}

//
//  UIConstants.swift
//  BeMyFamily
//
//  Created by Gucci on 4/19/24.
//

import UIKit

struct UIConstants {
    struct Frame {
        static let heartHeight = 28.0
        static let heartBorderHeight = 32.0
        static let shareHeight = 32.0
        static let feedImageHeight = 500.0
        static let screenWidth = UIScreen.main.bounds.width
        static let screenHeight = UIScreen.main.bounds.height
        static let screenSize = UIScreen.main.bounds.size
        static let screenWidthWithPadding = screenWidth - UIConstants.Padding.feedImemViewHorizontal
    }

    struct Padding {
        static let feedImemViewHorizontal = 16.0
    }

    struct Opacity {
        static let border = 0.85
    }

    struct Image {
        static let friendPlaceholder = "FriendPlaceholder"
        static let heart = "heart.fill"
        static let heartWithStroke = "heart"
        static let share = "square.and.arrow.up.circle.fill"
        static let filter = "line.3.horizontal.decrease.circle"
        static let reset = "arrow.uturn.backward"
    }

    struct Radius {
        static let mainImagePlaceholder = 16.0
    }

    struct Spacing {
        static let interFeedItem = 26.0
    }

    struct Line {
        static let feedItem = 3.0
    }

    struct App {
        static let feed = "Feed"
        static let favorite = "Favorite"
        static let filter = "Filter"
        static let feedIcon = "dog"
        static let favoriteIcon = "house.fill"
        static let shareMessage = "❤️Be my family🦮"
    }

    struct Date {
        static let  aDayBefore = -86400.0
    }

    struct FilterForm {
        static let showAll = "전체보기"
        static let title = "조건 설정"
    }
}

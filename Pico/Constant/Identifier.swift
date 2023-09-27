//
//  Identifier.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import Foundation

struct Identifier {
    struct ViewController {
        static let homeVC = "HomeViewController"
        static let mailVC = "MailViewController"
        static let likeVC = "LikeViewController"
        static let entVC = "EntViewController"
        static let mypageVC = "MypageViewController"
    }
    
    struct TableCell {
        static let mailTableCell = "MailListTableViewCell"
        static let SettingPrivateTableCell = "SettingPrivateTableCell"
        static let SettingNotiTableCell = "MailListTableViewCell"
        static let SettingTableCell = "SettingTableCell"
        static let topUserTableCell = "TopUserTableViewCell"
        static let middleUserTableCell = "MiddleUserTableViewCell"
        static let bottomUserTableCell = "BottomUserTableViewCell"
        static let notiTableCell = "NotificationTabelViewCell"
    }
    
    struct CollectionView {
        static let likeCell = "LikeCollectionViewCell"
        static let hobbyCollectionCell = "HobbyCollectionCell"
        static let mbtiCollectionCell = "mbtiCollectionCell"
    }
}

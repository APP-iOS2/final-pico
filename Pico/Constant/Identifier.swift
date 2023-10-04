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
        static let profileEditImageTableCell = "ProfileEditImageTableCell"
        static let profileEditNicknameTabelCell = "ProfileEditNicknameTabelCell"
        static let profileEditBirthTableCell = "ProfileEditBirthTableCell"
        static let profileEditLoactionTabelCell = "ProfileEditLoactionTabelCell"
        static let profileEditIntroTabelCell = "ProfileEditIntroTabelCell"
        static let profileEditTextTabelCell = "ProfileEditTextTabelCell"
        static let myPageCollectionTableCell = "MyPageCollectionTableCell"
        static let myPageMatchingTableCell = "MyPageMatchingTableCell"
        static let myPageDefaultTableCell = "MyPageDefaultTableCell"
        static let storeTableCell = "StoreTableCell"
    }
    
    struct CollectionView {
        static let likeCell = "LikeCollectionViewCell"
        static let hobbyCollectionCell = "HobbyCollectionCell"
        static let mbtiCollectionCell = "mbtiCollectionCell"
        static let filterMbtiCollectionCell = "filterMbtiCollectionCell"
        static let profileEditCollectionCell = "ProfileEditCollectionCell"
        static let myPageCollectionCell = "MyPageCollectionCell"
    }
}

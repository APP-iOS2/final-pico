//
//  SectionModel.swift
//  Pico
//
//  Created by 김민기 on 2023/10/11.
//

import Foundation
import RxDataSources

struct SectionModel {
    var items: [Item]
}

extension SectionModel: SectionModelType {
    init(original: SectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}

enum Item {
    case profileEditImageTableCell(images: [String])
    case profileEditNicknameTabelCell
    case profileEditLoactionTabelCell(location: String)
    case profileEditIntroTabelCell(content: String)
    case profileEditTextTabelCell(title: String, content: String?)
}

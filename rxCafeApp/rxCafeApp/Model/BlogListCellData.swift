//
//  BlogListCellData.swift
//  rxCafeApp
//
//  Created by seungbong on 2022/09/04.
//

import Foundation

struct BlogListCellData: Decodable {
    var thumbnail: String?
    var blogname: String?
    var title: String?
//    var datetime: Date?
    var contents: String?
}

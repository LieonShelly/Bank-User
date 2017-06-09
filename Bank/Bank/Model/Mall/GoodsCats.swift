//
//  GoodsCats.swift
//  Bank
//
//  Created by yang on 16/4/14.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 商品分类列表
class GoodsCatsList: Model {
    var cats: [GoodsCats]?
    
    override func mapping(map: Map) {
        cats <- map["cats"]
    }
}

/// 商品一级分类
class GoodsCats: Model {
    var catID: String = ""
    var catName: String = ""
    var catIcon: URL?
    var catType: GoodsType = .merchandise
    var subCats: [GoodsCats] = []
    
    override func mapping(map: Map) {
        catID <- map["cat_id"]
        catName <- map["cat_name"]
        catIcon <- (map["cat_icon"], URLTransform())
        catType <- map["type"]
        subCats <- map["sub_cats"]
    }
}

/// 商品二级分类
//class GoodsCats: Model {
//    var catID: String = ""
//    var catName: String?
//    var catIcon: NSURL?
//    var catType: GoodsType?
//    var isCheck: Bool = false
//    override func mapping(map: Map) {
//        catID <- map["cat_id"]
//        catName <- map["cat_name"]
//        catIcon <- (map["cat_icon"], URLTransform())
//        catType <- map["type"]
//    }
//}

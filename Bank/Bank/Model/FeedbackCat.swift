//
//  FeedbackCat.swift
//  Bank
//
//  Created by 杨锐 on 16/8/25.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 反馈分类
class FeedbackCat: Model {
    var catID: String = ""
    var catName: String?
    var subCats: [FeedbackCat] = []
    
    override func mapping(map: Map) {
        catID <- map["cat_id"]
        catName <- map["cat_name"]
        subCats <- map["sub_cats"]
    }
}

/// 反馈分类列表
class FeedbackCatList: Model {
    var catList: [FeedbackCat]?
    
    override func mapping(map: Map) {
        catList <- map["cat_list"]
    }
}

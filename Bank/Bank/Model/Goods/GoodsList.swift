//
//  GoodsList.swift
//  Bank
//
//  Created by yang on 16/3/17.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 商品列表
class GoodsList: Model {
    var totalPage: Int?
    var totalItems: Int?
    var currentPage: Int?
    var perpage: Int?
    var items: [Goods]?
    
    override func mapping(map: Map) {
        totalPage <- (map["total_page"], IntStringTransform())
        totalItems <- (map["total_items"], IntStringTransform())
        currentPage <- (map["current_page"], IntStringTransform())
        perpage <- (map["perpage"], IntStringTransform())
        items <- map["items"]
    }

}

/// 热门商品列表
class HotGoodsList: Model {
    var hotGoodsList: [Goods]?
    
    override func mapping(map: Map) {
        hotGoodsList <- map["hot_goods_list"]
    }
}

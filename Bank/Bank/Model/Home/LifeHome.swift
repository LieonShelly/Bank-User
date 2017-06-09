//
//  LifeHome.swift
//  Bank
//
//  Created by yang on 16/3/11.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 首页数据
class LifeHome: Model {
    var productList: [Product]?
    var goodsList: [Goods]?
    var goodsCatsList: [GoodsCats]?
    
    override func mapping(map: Map) {
        productList <- map["finance_product_list"]
        goodsList <- map["goods_list"]
        goodsCatsList <- map["goods_cat_list"]
    }
}

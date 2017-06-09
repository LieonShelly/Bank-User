//
//  BoughtProducts.swift
//  Bank
//
//  Created by yang on 16/3/14.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

//已购产品
class BoughtProducts: Model {
    var totalPage: Int?
    var totalItems: Int?
    var items: [Product]?
    
    override func mapping(map: Map) {
        totalPage <- (map["total_page"], IntStringTransform())
        totalItems <- (map["total_items"], IntStringTransform())
        items <- map["items"]
    }
}

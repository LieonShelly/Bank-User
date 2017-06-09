//
//  Banner.swift
//  Bank
//
//  Created by yang on 16/3/11.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

//banner广告
class Banner: Model {
    var imageURL: URL?
    var url: URL?
    
    override func mapping(map: Map) {
        imageURL <- (map["img"], URLTransform())
        url <- (map["url"], URLTransform())
    }
}

//广告列表
class BannerList: Model {
    var banners: [Banner]?
    
    override func mapping(map: Map) {
        banners <- map["banners"]
    }
}

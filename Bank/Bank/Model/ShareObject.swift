//
//  ShareToQQAndWX.swift
//  Bank
//
//  Created by Herb on 16/7/20.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

class ShareObject {
    var thumbnail: UIImage?
    var title: String?
    var description: String?
    var url: URL?
}

class ShareAppContent: Model {
    var `id`: String?
    var title: String?
    var detail: String?
    var thumb: URL?
    var url: URL?
    
    override func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        detail <- map["detail"]
        thumb <- (map["thumb"], URLTransform())
        url <- (map["url"], URLTransform())
    }
}

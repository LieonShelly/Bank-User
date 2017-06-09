//
//  ImageCaptcha.swift
//  Bank
//
//  Created by yang on 16/3/11.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

//图形验证码
class ImageCaptcha: Model {
    var imageData: String?

    override func mapping(map: Map) {
        imageData <- map["img_data"]
    }
}

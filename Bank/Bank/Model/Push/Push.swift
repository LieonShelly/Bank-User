//
//  Push.swift
//  Bank
//
//  Created by lieon on 2017/1/19.
//  Copyright © 2017年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

 class PushCertificate: Model {
    var pem: String?
    var password: String = "20160103"
    
   override func mapping(map: Map) {
        pem <- map["pem"]
        password <- map["password"]
    }
}

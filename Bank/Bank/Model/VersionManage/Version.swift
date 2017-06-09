//
//  Version.swift
//  Bank
//
//  Created by lieon on 16/8/31.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

class Version: Model {
    /// 比较版本用versionName和v+本地版本号比较
    var versionName: String = ""
    var versionNum: String = ""
    var isForcrUpdate: Bool = false
    var downloadUrl: String = ""
    var desc: String = ""
    
    override func mapping(map: Map) {
        versionName <- map["version_name"]
        isForcrUpdate <- (map["is_force_update"], BoolStringTransform())
        downloadUrl <- map["download_url"]
        versionNum <- map["version_no"]
        desc <- map["desc"]
    }
}

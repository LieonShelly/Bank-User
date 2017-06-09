//
//  LotteryHome.swift
//  Bank
//
//  Created by yang on 16/7/18.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 砸金蛋抽奖首页
class LotteryHome: Model {
    var winList: [WinInfo]?
    var poolList: [Prize]?
    
    override func mapping(map: Map) {
        winList <- map["win_list"]
        poolList <- map["pool_list"]
    }
}

/// 中奖信息
class WinInfo: Model {
    var mobile: String?
    var title: String?
    
    override func mapping(map: Map) {
        mobile <- map["mobile"]
        title <- map["title"]
    }
}

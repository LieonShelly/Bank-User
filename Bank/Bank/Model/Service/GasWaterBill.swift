//
//  GasWaterBill.swift
//  Bank
//
//  Created by yang on 16/3/11.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper
//燃气费或水费
class GasWaterBill: Model {
    /// 单位名
    var gasName: String?
    /// 户名
    var name: String?
    //应缴费金额
    var bill: Float?
    
    override func mapping(map: Map) {
        gasName <- map["gas_name"]
        name <- map["name"]
        bill <- (map["bill"], FloatStringTransform())
    }
}

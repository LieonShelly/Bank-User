//
//  RegionCode.swift
//  Bank
//
//  Created by yang on 16/3/11.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

//区域编码

/// 省级区域编码
class ProvinceRegions: Model {
    //行政编码
    var code: String?
    //行政级别
    var cityRegions: [CityRegions]?
    var name: String?

    override func mapping(map: Map) {
        code <- map["code"]
        cityRegions <- map["regions"]
        name <- map["name"]
    }
}

/// 市级区域编码
class CityRegions: Model {
    var name: String?
    var code: String?
    var districtRegions: [DistrictRegions]?
    
    override func mapping(map: Map) {
        name <- map["name"]
        code <- map["code"]
        districtRegions <- map["regions"]
    }
}

/// 区级区域编码
class  DistrictRegions: Model {
    var name: String?
    var code: String?
    
    override func mapping(map: Map) {
        name <- map["name"]
        code <- map["code"]
    }
}

class RegionCodeList: Model {
    var regions: [ProvinceRegions]?
    
    override func mapping(map: Map) {
        regions <- map["regions"]
    }
}

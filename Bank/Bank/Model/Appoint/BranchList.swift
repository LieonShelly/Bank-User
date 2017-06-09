//
//  BranchList.swift
//  Bank
//
//  Created by yang on 16/3/10.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper
import CoreLocation

/// 网点列表
class BranchList: Model {
    var totalPage: Int?
    var totalItems: Int?
    var items: [Branch]?
    
    override func mapping(map: Map) {
        totalPage <- (map["total_page"], IntStringTransform())
        totalItems <- (map["total_items"], IntStringTransform())
        items <- map["items"]
    }
    
}

/// 网点
class Branch: Model {
    var branchID: String = ""
    var name: String?
    var address: String?
    var tel: String?
    var lat: Double?
    var lng: Double?
    
    var coordinate: CLLocationCoordinate2D? {
        if let lat = lat, let lng = lng {
            return CLLocationCoordinate2D(latitude: lat, longitude: lng)
        }
        return nil
    }
    
    override func mapping(map: Map) {
        branchID <- map["branch_id"]
        name <- map["name"]
        address <- map["address"]
        tel <- map["tel"]
        lat <- (map["lat"], DoubleStringTransform())
        lng <- (map["lng"], DoubleStringTransform())
    }
}

extension Branch: Equatable {}

func == (lhs: Branch, rhs: Branch) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

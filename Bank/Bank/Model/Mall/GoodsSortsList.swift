//
//  GoodsSortsList.swift
//  Bank
//
//  Created by yang on 16/6/12.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper
class GoodsSortsList: Model {
    var orderbyList: [GoodsSort]?
    
    override func mapping(map: Map) {
        orderbyList <- map["orderby_list"]
    }
}

class GoodsSort: Model {
    var sortID: String?
    var name: String?
    var image: UIImage?
    
    override func mapping(map: Map) {
        sortID <- map["id"]
        name <- map["name"]
        image <- map["image"]
    }
    
    static func setBrandZoneSort() -> [GoodsSort] {
        var sortArray: [GoodsSort] = []
        let sort1 = GoodsSort()
        sort1.sortID = "1"
        sort1.name = R.string.localizable.string_title_default()
//        sort1.image = R.image
        sortArray.append(sort1)
        
        let sort2 = GoodsSort()
        sort2.sortID = "1"
        sort2.name = R.string.localizable.string_title_highest_sales()
        sortArray.append(sort2)
        
        let sort3 = GoodsSort()
        sort3.sortID = "2"
        sort3.name = R.string.localizable.string_title_latest_in()
        sortArray.append(sort3)
        
        let sort4 = GoodsSort()
        sort4.sortID = "3"
        sort4.name = R.string.localizable.string_title_highest_score()
        sortArray.append(sort4)
        return sortArray
    }
    
    static func setOfflineEventSort() -> [GoodsSort] {
        var sortArray: [GoodsSort] = []
        let sort1 = GoodsSort()
        sort1.sortID = "0"
        sort1.name = R.string.localizable.string_title_default()
        sortArray.append(sort1)
        
        let sort2 = GoodsSort()
        sort2.sortID = "1"
        sort2.name = R.string.localizable.string_title_latest_release()
        sortArray.append(sort2)
        
        let sort3 = GoodsSort()
        sort3.sortID = "2"
        sort3.name = R.string.localizable.string_title_most_points()
        sortArray.append(sort3)
        
        let sort4 = GoodsSort()
        sort4.sortID = "3"
        sort4.name = R.string.localizable.string_title_most_popular()
        sortArray.append(sort4)
        
        let sort5 = GoodsSort()
        sort5.sortID = "4"
        sort5.name = R.string.localizable.string_title_end_sign()
        sortArray.append(sort5)
        
        return sortArray

    }
}

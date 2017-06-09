//
//  NewsList.swift
//  Bank
//
//  Created by yang on 16/3/18.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 资讯列表
class NewsList: Model {
    var totalPage: Int?
    var totalItems: Int?
    var currentPage: Int?
    var perpage: Int?
    var items: [News]?
    
    override func mapping(map: Map) {
        totalPage <- (map["total_page"], IntStringTransform())
        totalItems <- (map["total_items"], IntStringTransform())
        currentPage <- (map["current_page"], IntStringTransform())
        perpage <- (map["perpage"], IntStringTransform())
        items <- map["items"]
    }

}

class News: Model {
    var newsID: String = ""
    var cover: URL?
    var title: String = ""
    /// 摘要
    var summary: String?
    /// 发布时间
    var createdTime: Date?
    var isRead: Bool = false
    
    var informationID: String?
    var informationTitle: String = ""
    
    var html: String?
    var shareURL: URL?
    
    override func mapping(map: Map) {
        newsID <- map["id"]
        cover <- (map["cover"], URLTransform())
        title <- map["title"]
        summary <- map["summary"]
        createdTime <- (map["created"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        isRead <- (map["is_read"], BoolStringTransform())
        informationID <- map["information_id"]
        informationTitle <- map["information_title"]
        html <- map["html"]
        shareURL <- (map["share_url"], URLTransform())
    }
    
}

/// 资讯分类列表
class NewsTypeList: Model {
    var typeList: [NewsTypeObject]?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        typeList <- map["type_list"]
    }
}

/// 置顶资讯列表
class TopNewsList: Model {
    var topNews: [News]?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        topNews <- map["top_news"]
    }
}

class NewsTypeObject: Model {
    var typeID: String?
    var name: String?
    var key: String?
    
    override func mapping(map: Map) {
        typeID <- map["type_id"]
        name <- map["name"]
        key <- map["key"]
    }
}

class BankHome: Model {
    var unRead: Int = 0
    
    override func mapping(map: Map) {
        unRead <- (map["unread_news_count"], IntStringTransform())
    }
}

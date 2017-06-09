//
//  ReplyContent.swift
//  Bank
//
//  Created by yang on 16/3/10.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/*
 items[x].reply_content.content_id	ID
 items[x].reply_content.content_type	大分类ID
 items[x].reply_content.content_type_name	大分类名称
 items[x].reply_content.content_subtype	子分类
 items[x].reply_content.content_subtype_name	子分类名称
 items[x].reply_content.title	回复内容标题
 items[x].reply_content.content	回复内容摘要
 items[x].reply_content.detail_link	详情链接
 */

/// 管家回复
class ReplyContent: Model {
    var content: String = ""
    var contentID: String = ""
    var contentType: ReplyContentType?
    var contentTypeName: String?
    var contentSubType: ReplyContentSubType?
    var contentSubTypeName: String?
    var title: String?
    var detailLink: URL?

    override func mapping(map: Map) {
        contentID <- map["content_id"]
        contentType <- map["content_type"]
        contentTypeName <- map["content_type_name"]
        contentSubType <- map["content_subtype"]
        contentSubTypeName <- map["content_subtype_name"]
        content <- map["content"]
        detailLink <- (map["detail_link"], URLTransform())
    }
}

// TODO: 
class SharedProduct: Model {
    
}

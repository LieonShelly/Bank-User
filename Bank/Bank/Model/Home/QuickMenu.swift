//
//  QuickMenu.swift
//  Bank
//
//  Created by yang on 16/3/14.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 快捷菜单
class QuickMenu: Model {
    var menuID: String = ""
    var menuName: String = ""
    var icon: URL?
    var url: URL?
    var editIcon: URL?
    /// 是否系统默认
    var isDefault: Bool = false
    /// 是否已选
    var isSelected: Bool = false
    /// 是否热门
    var isHot: Bool = false
    /// 是否是新菜单
    var isNew: Bool = false
    var image: UIImage?
    
    override func mapping(map: Map) {
        menuID <- map["menu_id"]
        menuName <- map["menu_name"]
        icon <- (map["icon"], URLTransform())
        url <- (map["url"], URLTransform())
        editIcon <- (map["edit_icon"], URLTransform())
        isDefault <- (map["is_default"], BoolStringTransform())
        isSelected <- (map["is_selected"], BoolStringTransform())
        isHot <- (map["is_hot"], BoolStringTransform())
        isNew <- (map["is_new"], BoolStringTransform())
    }
    
    class func addNewMenu() -> QuickMenu {
        let menu = QuickMenu()
        menu.menuID = "-1"
        menu.image = R.image.btn_add()
        menu.menuName = "添加"
        let dic = GotoPageData()
        dic.action = URLAction.gotoPage
        dic.extra?.pageID = PageID.shortcutSetting
        var url = URLComponents()
        url.scheme = Const.URLScheme
        url.host = dic.toJSONString()
        menu.url = url.url
        return menu
    }

}

extension QuickMenu: Hashable {
    static func == (lhs: QuickMenu, rhs: QuickMenu) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    var hashValue: Int {
        return self.menuID.hashValue
    }
}

/// 获取快捷菜单
class GetQuickMenu: Model {
    var menuList: [QuickMenu]?
    
    override func mapping(map: Map) {
        menuList <- map["menu_list"]
    }
}

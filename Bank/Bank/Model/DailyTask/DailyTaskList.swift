//
//  DailyTaskList.swift
//  Bank
//
//  Created by yang on 16/3/18.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

class DailyTaskList: Model {
    var taskList: [DailyTask]?
    
    override func mapping(map: Map) {
        taskList <- map["task_list"]
    }
}

class DailyTask: Model {
    var taskID: String = ""
    var typeID: String = ""
    var title: String?
    /// 需要的次数
    var goal: Int?
    var imageURL: URL?
    var point: Int = 0
    var startTime: Date?
    var endTime: Date?
    /// 重复领取的次数
    var repeatTimes: Int?
    /// 是否可以重复领取
    var isRepeatable: Bool?
    var status: TaskStatus?
    var type: TaskType?
    var html: String?
    
    override func mapping(map: Map) {
        taskID <- map["task_id"]
        typeID <- map["type_id"]
        title <- map["title"]
        goal <- (map["goal"], IntStringTransform())
        imageURL <- (map["cover"], URLTransform())
        point <- (map["point"], IntStringTransform())
        startTime <- (map["start_time"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        endTime <- (map["end_time"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        repeatTimes <- (map["repeat_times"], IntStringTransform())
        isRepeatable <- (map["is_repeatable"], BoolStringTransform())
        type <- map["type"]
        status <- map["status"]
        html <- map["html"]
    }
}

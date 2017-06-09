//
//  AdvertAnswer.swift
//  Bank
//
//  Created by yang on 16/3/17.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

class AdvertAnswer: Model {
    var answerID: String = ""
    var text: String?
    
    override func mapping(map: Map) {
        answerID <- map["id"]
        text <- map["text"]
    }
}

class AdvertQuestion: Model {
    var question: String?
    var answerList: [AdvertAnswer]?
    var answerType: AnswerType?
    
    override func mapping(map: Map) {
        question <- map["question"]
        answerList <- map["answer_list"]
        answerType <- map["answer_type"]
    }
}

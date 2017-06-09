//
//  MyOrder.swift
//  AppPayDemo
//
//  Created by Leon King on 1/29/16.
//  Copyright © 2016 QinYejun. All rights reserved.
//

import Foundation

struct MyOrder {
    let idid: Int
    let title: String
    let url: String
    let price: Double
    let paid: Bool
    
    init(idid: Int,
        title: String,
        url: String,
        price: Double,
        paid: Bool) {
            self.idid = idid
            self.title = title
            self.url = url
            self.price = price
            self.paid = paid

    }
}

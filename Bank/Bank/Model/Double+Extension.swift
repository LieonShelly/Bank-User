//
//  Double+Extension.swift
//  AppPayDemo
//
//  Created by Leon King on 1/29/16.
//  Copyright © 2016 QinYejun. All rights reserved.
//

import Foundation

extension Double {
    func format(_ fmt: String) -> String {
        return NSString(format: "%\(fmt)f" as NSString, self) as String
    }
}

//
//  CodeButton.swift
//  Bank
//
//  Created by 糖otk on 2017/2/17.
//  Copyright © 2017年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class CodeButton: UIButton {

    var time = 60
    var timer = Timer()
    
    override func awakeFromNib() {
        
        self.setTitleColor(UIColor.white, for: .normal)
        self.setTitleColor(UIColor.gray, for: .selected)
        self.tintColor = UIColor.clear
        if self.isSelected == false {
            self.setTitle("获取验证码", for: .normal)
            self.backgroundColor = UIColor(hex: 0x00A8FE)
        } else {
            let title = "\(time)"+"s"
            self.setTitle(title, for: .normal)
            self.backgroundColor = UIColor(hex: 0xc9c9ce)
        }
    }
    
    func starTime() {
        let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: self, repeats: true)
        RunLoop.current.add(timer, forMode: .commonModes)
        self.timer = timer
        self.isEnabled = false
        self.isSelected = true
        let title = "\(time)"+"s"
        self.setTitle(title, for: .normal)
        self.setTitleColor(UIColor(hex: 0x898989), for: .normal)
        self.backgroundColor = UIColor(hex: 0xc9c9ce)
    }
    
    func updateTime() {
        time -= 1
        let title = "\(time)"+"s"
        self.setTitle(title, for: .normal)
        if time == 0 {
            time = 60
            timer.invalidate()
            self.isEnabled = true
            self.isSelected = false
            self.setTitle("重新发送", for: .normal)
        }
        if self.isSelected == true {
            self.setTitleColor(UIColor(hex: 0x898989), for: .normal)
            self.backgroundColor = UIColor(hex: 0xc9c9ce)
        } else {
            self.setTitleColor(UIColor.white, for: .normal)
            self.backgroundColor = UIColor(hex: 0x00A8FE)
        }
    }

}

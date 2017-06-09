//
//  CouponUseSuccessViewController.swift
//  Bank
//
//  Created by 杨锐 on 2016/10/20.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import URLNavigator

class CouponUseSuccessViewController: BaseViewController {
    
    var dismissBlock: (() -> Void)?
    var considerHandleBlock: (() -> Void)?
    var awardHandleBlock: ((_ awardID: String?) -> Void)?
    var awardID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// 取消
    @IBAction func dismissAction(_ sender: UIButton?) {
        if let block = dismissBlock {
            block()
        }
    }
    
    /// 考虑一下
    @IBAction func considerAction(_ sender: UIButton) {
        if let block = considerHandleBlock {
            block()
        }
    }
    
    /// 我要打赏
    @IBAction func rewardAction(_ sender: UIButton) {
        if let block = awardHandleBlock {
            block(awardID)
        }
    }

}

//
//  TransResultViewController.swift
//  Bank
//
//  Created by Koh Ryu on 16/7/30.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class TransResultViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var backView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func donwHandle() {
        _ = navigationController?.popToRootViewController(animated: true)
    }

}

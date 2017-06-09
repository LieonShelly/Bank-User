//
//  SplashViewController.swift
//  Bank
//
//  Created by Koh Ryu on 16/5/24.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    
    @IBOutlet fileprivate weak var versionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let text = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            versionLabel.text = "Build " + text
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

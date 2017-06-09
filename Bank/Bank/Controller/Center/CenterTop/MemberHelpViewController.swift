//
//  MemberHelpViewController.swift
//  Bank
//
//  Created by Mac on 15/12/3.
//  Copyright © 2015年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class MemberHelpViewController: BaseViewController {

    @IBOutlet weak fileprivate var memberHelpWebView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = URL(string: "file:///Users/mac/Desktop/DJ/BankHtml5/APP/IAddMembers.html") {
            memberHelpWebView.loadRequest(URLRequest(url: url))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

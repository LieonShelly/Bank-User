//
//  LifeServiceViewController.swift
//  Bank
//
//  Created by Koh Ryu on 11/20/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import URLNavigator

final class LifeServiceViewController: BaseViewController {
    
    private var serviceType: LifeServiceType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Method
    
    @IBAction func finishPayBill(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func buttonHandle(sender: UIButton) {
        guard let type = LifeServiceType(rawValue: sender.tag) else {
            return
        }
        serviceType = type
        if type == .Tel {
            performSegueWithIdentifier(R.segue.lifeServiceViewController.showPhoneBill, sender: nil)
        } else {
            performSegueWithIdentifier(R.segue.lifeServiceViewController.showOtherServiceVC, sender: nil)
        }
    }
    
    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == R.segue.lifeServiceViewController.showOtherServiceVC.identifier {
            if let vc = segue.destinationViewController as? FeeQueryViewController {
                vc.serviceType = serviceType
            }
        }
    }
}

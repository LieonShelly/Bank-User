//
//  WaterFeeViewController.swift
//  Bank
//
//  Created by Koh Ryu on 11/23/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class FeeViewController: BaseViewController {
    
    @IBOutlet private weak var companyDescLabel: UILabel!
    @IBOutlet private weak var companyTextField: UITextField!
    @IBOutlet private weak var numDescLabel: UILabel!
    @IBOutlet private weak var numTextField: UITextField!
    @IBOutlet private weak var ownerDescLabel: UILabel!
    @IBOutlet private weak var ownerTextField: UITextField!
    @IBOutlet private weak var billTextField: UITextField!
    
    var serviceType: LifeServiceType!
    var queryString: String!
    var company: String?
    
    var fee: CGFloat = CGFloat(arc4random() % 500) + 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = serviceType.title
        
        companyDescLabel.text = serviceType.companyDesc
        
        if let data = serviceType.companyData {
            companyTextField.text = data[0]
        }
        
        numDescLabel.text = serviceType.numberDesc
        if serviceType == .Ticket {
            companyTextField.text = queryString
            numTextField.text = "张三"
            ownerTextField.text = "138 8888 8888"
        } else {
            companyTextField.text = company
            numTextField.text = queryString
            ownerTextField.text = serviceType.ownerDesc
        }
        billTextField.text = "\(fee)元"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Method
    @IBAction func showPayBillVC() {
        performSegueWithIdentifier(R.segue.feeViewController.showPayBillVC, sender: nil)
    }
    
    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? PayBillViewController {
            vc.serviceName = serviceType.title
            vc.fee = fee
            if let data = serviceType.companyData {
                if data.isEmpty == false {
                    vc.companyName = data[0]
                }
            }
        }
    }

}

//
//  PayBillViewController.swift
//  Bank
//
//  Created by Koh Ryu on 11/23/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import LocalAuthentication

class PayBillViewController: BaseViewController {
    
    @IBOutlet private weak var billLabel: UILabel!
    @IBOutlet private weak var totalLabel: UILabel!
    @IBOutlet private weak var companyLabel: UILabel!
    @IBOutlet private weak var paymentLabel: UILabel!
    
    var companyName: String?
    var serviceName: String!
    var fee: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var name = serviceName
        if let company = companyName {
            name += "(" + company + ")"
        }
        companyLabel.text = name
        billLabel.text = "\(fee)元"
        totalLabel.text = billLabel.text
        helpHtmlName = "LoveHelpForPayment"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showAlertController(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "好的", style: .Default) { (action) in
            // use newer R.swift to avoid using string
            self.performSegueWithIdentifier(R.segue.payBillViewController.finishPayBill, sender: nil)
        }
        alertController.addAction(action)
        presentViewController(alertController, animated: true, completion: nil)
    }

    @IBAction func authorize() {
        //  touch id
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "请认证你的指纹"
            context.evaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: { (success, error) -> Void in
                if success {
                    self.performSelectorOnMainThread(#selector(self.showAlertController(_:)), withObject: "支付成功", waitUntilDone: false)
                }
            })
        }
    }

}

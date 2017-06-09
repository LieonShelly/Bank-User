//
//  PayDebtViewController.swift
//  Bank
//
//  Created by Koh Ryu on 11/30/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class PayDebtViewController: BaseTableViewController {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var billLabel: UILabel!
    @IBOutlet private weak var timeLabeL: UILabel!
    @IBOutlet private weak var restLabel: UILabel!
    @IBOutlet private weak var amountTextField: UITextField!
    @IBOutlet private weak var amountRightLabel: UILabel!

//    var creditBill: CreditBill?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        amountTextField.rightViewMode = .Always
        amountTextField.rightView = amountRightLabel
        
//        guard let creditBill = creditBill else {
//            return
//        }
//        imageView.image = creditBill.image
//        nameLabel.text = creditBill.name + "asdfjas;ldkfja;lskdfj"
//        billLabel.amountWithUnit(creditBill.bill, amountFontSize: 13, unitFontSize: 13)
//        timeLabeL.timeWithFormat(creditBill.expireDate)
//        restLabel.amountWithUnit(creditBill.restAmount, color: UIColor.colorFromHex(CustomKey.Color.MainBlueColor), amountFontSize: 25, unitFontSize: 13)
        tableView.configBackgroundView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Method
    
    @IBAction func payDebtHandle() {
    }
    
    @IBAction func dissmissKeyboard() {
        view.endEditing(true)
    }

}

// MARK: Table View Delegate
extension PayDebtViewController {
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return Const.TableView.SectionHeight.Header17
        }
        return Const.TableView.SectionHeight.Header0
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return Const.TableView.SectionHeight.Header10
        }
        return Const.TableView.SectionHeight.Header17
    }

}

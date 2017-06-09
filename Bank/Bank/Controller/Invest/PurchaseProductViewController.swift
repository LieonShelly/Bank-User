//
//  PurchaseProductViewController.swift
//  Bank
//
//  Created by Koh Ryu on 12/1/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class PurchaseProductViewController: BaseTableViewController {
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var percentLabel: UILabel!
    @IBOutlet private weak var leastLabel: UILabel!
    @IBOutlet private weak var expireLabel: UILabel!
    
    var product: Product?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let product = product {
            configInfo(product)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Method
    
    func configInfo(product: Product) {
        nameLabel.text = product.title
        percentLabel.amountWithUnit(product.profit, amountFontSize: 35, unitFontSize: 20, unit: "%", decimalPlace: 1)
        leastLabel.amountWithUnit(product.minAmount,
        color: UIColor.colorFromHex(0x666666), amountFontSize: 13, unitFontSize: 13)
        expireLabel.timeWithFormat(product.interestEnd)
    }
    
    @IBAction func dimissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Table View Delegate
extension PurchaseProductViewController {
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 17
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
}

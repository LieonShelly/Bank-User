//
//  EAccountViewController.swift
//  Bank
//
//  Created by Koh Ryu on 11/27/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator

class EAccountViewController: BaseViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var totalLabel: UILabel!
    @IBOutlet private weak var profitLabel: UILabel!
    @IBOutlet private weak var balanceLabel: UILabel!
    @IBOutlet private weak var headerView: UIView!
    
    private var accountInfo: EAccount = EAccount()
    private var purchasedProducts: [Product] = []
    private var selectProduct: Product?
    private var showCharge: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(R.nib.eProductTableViewCell)
        tableView.rowHeight = UITableViewAutomaticDimension
        tabBarController?.tabBar.hidden = true
        tableView.configBackgroundView()
        totalLabel.amountWithUnit(Float(accountInfo.assets), color: UIColor.whiteColor(), amountFontSize: 36, unitFontSize: 20)
        requestData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == R.segue.eAccountViewController.showPurchasedProductVC.identifier {
            if let vc = segue.destinationViewController as? PurchasedProductViewController {
                vc.product = selectProduct
            }
        }
        if segue.identifier == R.segue.eAccountViewController.showImportExportVC.identifier {
            if let vc = segue.destinationViewController as? ImportExportViewController {
                vc.isImport = showCharge
            }
        }
    }
    
    @IBAction func showChargeWithdraw(sender: UIButton) {
        showCharge = sender.tag == 0
        performSegueWithIdentifier(R.segue.eAccountViewController.showImportExportVC, sender: nil)
    }
    
    private func requestData(page: Int = 1) {
        let param = InvestParameter()
        param.page = page
        
        let req: Promise<InvestProductListData> = handleRequest(Router.Endpoint(endpoint: InvestPath.PurchasedProductList, param: param))
        req.then { (value) -> Void in
            if let items = value.data?.items {
                self.purchasedProducts = items
                self.tableView.reloadData()
            }
        }.error { (error) in
            if let err = error as? AppError {
                Navigator.showAlertWithoutAction(nil, message: err.toError().localizedDescription)
            }
        }
    }
 
}

// MARK: Table View Delegate
extension EAccountViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.contentView.backgroundColor = .whiteColor()
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "  已购产品"
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectProduct = purchasedProducts[indexPath.row]
        performSegueWithIdentifier(R.segue.eAccountViewController.showPurchasedProductVC, sender: nil)
    }
}

// MARK: Table View Data Source
extension EAccountViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purchasedProducts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(R.nib.eProductTableViewCell, forIndexPath: indexPath) else {
            return UITableViewCell()
        }
        cell.configInfo(purchasedProducts[indexPath.row])
        return cell
    }
}

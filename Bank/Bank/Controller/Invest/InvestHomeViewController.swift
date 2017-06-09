//
//  InvestViewController.swift
//  Bank
//
//  Created by Koh Ryu on 11/17/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit
import URLNavigator
import PullToRefresh

class InvestHomeViewController: BaseViewController {
  
    @IBOutlet private weak var tableView: UITableView!
    
    private var selectedProduct: Product?
    private var datas: [Product] = []
    
    private var currentPage: Int = 0
    private var topRefresher = PullToRefresh()
    private var bottomRefresher = PullToRefresh()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(R.nib.investTableViewCell)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.backgroundView = nil
        tableView.backgroundColor = .colorFromHex(CustomKey.Color.ViewBackgroundColor)

        topRefresher.position = .Top
        bottomRefresher.position = .Bottom
        tableView.addPullToRefresh(topRefresher) { [weak self] in
            self?.requestListData()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        requestListData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func addInfinite() {
        tableView.addPullToRefresh(bottomRefresher) { [weak self] in
            self?.requestListData(self?.currentPage ?? 1 + 1)
            self?.tableView.endRefreshing(at: .Bottom)
        }
    }
    
    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == R.segue.investHomeViewController.showProductDetailVC.identifier {
            if let vc = segue.destinationViewController as? ProductDetailViewController {
                vc.productID = selectedProduct?.productID
            }
        }
    }
    
    func requestListData(page: Int = 1) {
        let param = InvestProductParameter()
        param.page = page
        param.perPage = 20
        let req: Promise<InvestProductListData> = handleRequest(Router.Endpoint(endpoint: InvestProductPath.ProductList, param: param))
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        req.then { value -> Void in
            if let items = value.data?.items where !items.isEmpty {
            if let items = value.data?.items where items.isEmpty == flase {
                self.currentPage = page
                if self.currentPage == 1 {
                    self.datas = items
                    self.tableView.endRefreshing(at: .Top)
                } else {
                    self.datas.appendContentsOf(items)
                    self.tableView.endRefreshing(at: .Bottom)
                }
                if self.datas.count > 20 {
                    self.addInfinite()
                } else {
                    self.tableView.removePullToRefresh(self.bottomRefresher)
                }
                self.tableView.reloadData()
            }
            }.always {
                MBProgressHUD.hideHUDForView(self.view, animated: true)
            }.error { error in
                if let err = error as? AppError {
                    Navigator.showAlertWithoutAction(nil, message: err.toError().localizedDescription)
                }
        }
    }
}

extension InvestHomeViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 9
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let product = datas[indexPath.section]
        selectedProduct = product
        performSegueWithIdentifier(R.segue.investHomeViewController.showProductDetailVC, sender: nil)
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

}

extension InvestHomeViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return datas.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(R.nib.investTableViewCell, forIndexPath: indexPath) else {
            return UITableViewCell()
        }
        cell.configProduct(datas[indexPath.section])
        return cell
    }
}

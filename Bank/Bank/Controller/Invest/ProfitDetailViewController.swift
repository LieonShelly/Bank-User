//
//  IncomingDetailViewController.swift
//  Bank
//
//  Created by Koh Ryu on 11/30/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//

import UIKit

private let kTableHeaderHeight: CGFloat = 120.0

class ProfitDetailViewController: BaseTableViewController {
    
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var incomingLabel: UILabel!
    
//    private var profitDetail: [Repayment]
    
    var product: Product?

    override func viewDidLoad() {
        super.viewDidLoad()
//        guard let obj = product else {
//            return
//        }
//        incomingLabel.amountWithUnit(obj.incomeTotal ?? 0, color: .whiteColor(), amountFontSize: 36, unitFontSize: 25, fontWeight: UIFontWeightMedium)
        tableView.addSubview(headerView)
        tableView.contentInset = UIEdgeInsets(top: kTableHeaderHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -kTableHeaderHeight)
        clearsSelectionOnViewWillAppear = true
        tableView.registerNib(R.nib.detailTableViewCell)
        updateHeaderView()
        tableView.configBackgroundView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Method
    func updateHeaderView() {
        var headerRect = CGRect(x: 0, y: -kTableHeaderHeight, width: tableView.bounds.width, height: kTableHeaderHeight)
        if tableView.contentOffset.y < -kTableHeaderHeight {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
        }
        headerView.frame = headerRect
    }
    
    // MARK: Scroll View Delegate
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        updateHeaderView()
    }
    
    // MARK: Table View Delegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    // MARK: Table View Data Source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0//profitDetail.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.nib.detailTableViewCell, forIndexPath: indexPath)
//        cell.configInfo(profitDetail[indexPath.row])
        return cell ?? UITableViewCell()
    }

}

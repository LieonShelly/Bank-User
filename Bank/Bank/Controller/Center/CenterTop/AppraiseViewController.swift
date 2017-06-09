//
//  AppraiseViewController.swift
//  Bank
//
//  Created by yang on 16/1/21.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import URLNavigator
import PromiseKit
import MBProgressHUD

class AppraiseViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var bottomHeight: NSLayoutConstraint!

    var order: Order?
    fileprivate var goodsList: [Goods] = []
    fileprivate var goodsSorce: [GoodsReview] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if order?.isUserEvaluate == false {
            self.title = R.string.localizable.center_myorder_appraise_title1()
            bottomHeight.constant = 50
        } else {
            self.title = R.string.localizable.center_myorder_appraise_title2()
            bottomHeight.constant = 0
        }
        if let items = order?.goodsList {
            self.goodsList = items
            setTableView()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setTableView() {
        tableView.configBackgroundView()
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(R.nib.appraiseTableViewCell)
        tableView.register(R.nib.appraiseSectionHeaderView(), forHeaderFooterViewReuseIdentifier: R.nib.appraiseSectionHeaderView.name)
        
    }
    
    /**
     提交评价
     */
    @IBAction func appraiseAction(_ sender: UIButton) {
//        if order?.isUserEvaluate == true {
//            Navigator.showAlertWithoutAction(nil, message: R.string.localizable.alertTitle_order_evaluated())
//            return
//        }
        goodsSorce.removeAll()
        for cell in tableView.visibleCells {
            guard let theCell = cell as? AppraiseTableViewCell else {
                break
            }
            if theCell.grade == 0 {
                Navigator.showAlertWithoutAction(nil, message: R.string.localizable.alertTitle_evaluate_at_least_one_star())
                return
            }
            let goodsReview = GoodsReview()
            goodsReview.goodsID = theCell.goods?.goodsID
            goodsReview.score = theCell.grade
            goodsSorce.append(goodsReview)
        }
        requestAppraiseData()
    }
    
    /**
     评价商品
     */
    fileprivate func requestAppraiseData() {
        MBProgressHUD.loading(view: view)
        let param = OrderParameter()
        param.orderID = order?.orderID
        param.goodsReviews = goodsSorce
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( OrderPath.order(.review), param: param))
        req.then { (value) -> Void in
            self.setBackAlertViewController(nil, message: R.string.localizable.alertTitle_evaluation_sucess())
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { error in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
}

// MARK: - UITableViewDataSource
extension AppraiseViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goodsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.appraiseTableViewCell, for: indexPath) else {
            return UITableViewCell()
        }
        cell.configInfo(goodsList[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension AppraiseViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: R.nib.appraiseSectionHeaderView.name) as? AppraiseSectionHeaderView else {
            return nil
        }
        guard let order = order else {return UIView()}
        headerView.configInfo(order)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

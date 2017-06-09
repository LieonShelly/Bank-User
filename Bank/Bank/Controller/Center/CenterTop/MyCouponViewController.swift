//
//  MyCouponViewController.swift
//  Bank
//
//  Created by yang on 16/1/19.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import PullToRefresh
import MBProgressHUD

class MyCouponViewController: BaseViewController {

    @IBOutlet fileprivate weak var myCouponTableView: UITableView!
    fileprivate var selectedCoupon: Coupon?
    fileprivate var coupons: [Coupon] = []
    fileprivate var merchants: [Merchant] = []
    fileprivate var currentPage: Int = 1
    fileprivate lazy var noneView: NoneView = { return NoneView(frame: self.view.bounds, type: .coupon) }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        setTableView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CouponDetailViewController {
            vc.couponID = selectedCoupon?.couponID
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// 设置UITableView的相关属性
    fileprivate func setTableView() {
        myCouponTableView.configBackgroundView()
        myCouponTableView.rowHeight = 80
        myCouponTableView.register(R.nib.myCouponSectionHeaderView(), forHeaderFooterViewReuseIdentifier: R.nib.myCouponSectionHeaderView.name)
        myCouponTableView.register(R.nib.myCouponTableViewCell)
    }
    
    /**
     请求优惠券列表
    */
    fileprivate func requestList(_ page: Int = 1) {
        MBProgressHUD.loading(view: view)
        let param = OrderParameter()
        param.page = page
        param.perPage = 10000
        let req: Promise<CouponListData> = handleRequest(Router.endpoint( OrderPath.order(.couponOrderList), param: param))
        req.then { (value) -> Void in
            if value.isValid {
                if let items = value.data?.items {
                    self.currentPage = page
                    if self.currentPage == 1 {
                        self.coupons = items
                    } else {
                        self.coupons.append(contentsOf: items)
                    }
                    self.merchants.removeAll()
                    let dic = self.coupons.groupBy { $0.merchantID }
                    for (key, value) in dic {
                        let merchant = Merchant()
                        merchant.merchantID = key
                        merchant.storeName = value[0].storeName
                        merchant.couponList = value
                        self.merchants.append(merchant)
                    }
                    if self.merchants.isEmpty {
                        self.myCouponTableView.addSubview(self.noneView)
                        self.noneView.buttonHandleBlock = {
                            guard let vc = R.storyboard.mall.hotGoodsViewController() else { return }
                            vc.goodsType = .service
                            Navigator.push(vc)
                        }
                    } else {
                        self.noneView.removeFromSuperview()
                        self.myCouponTableView.reloadData()
                    }
                    
                }
            }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }

    }
    
}

// MARK: UITableViewDataSoruce
extension MyCouponViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let couponList = merchants[section].couponList {
            return couponList.count
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return merchants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: MyCouponTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.myCouponTableViewCell, for: indexPath) else {
            return UITableViewCell()
        }
        if let couponList = merchants[indexPath.section].couponList {
            cell.configInfo(couponList[indexPath.row])
        }
        return cell
       
    }

}

// MARK: UITableViewDelegate
extension MyCouponViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: R.nib.myCouponSectionHeaderView.name) as? MyCouponSectionHeaderView else {
            return nil
        }
        if section == 0 {
            header.topLineView.isHidden = true
        } else {
            header.topLineView.isHidden = false
        }
        header.titleLabel.text = merchants[section].storeName
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let CouponList =  merchants[indexPath.section].couponList else {return}
        selectedCoupon = CouponList[indexPath.row]
        self.performSegue(withIdentifier: R.segue.myCouponViewController.showCouponDetailVC, sender: nil)
    }
}

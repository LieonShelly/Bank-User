//
//  MoreBrandsViewController.swift
//  Bank
//
//  Created by yang on 16/2/23.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import PullToRefresh
import URLNavigator
import MBProgressHUD

class MoreBrandsViewController: BaseViewController {

    @IBOutlet fileprivate weak var brandsTableView: UITableView!
    fileprivate var selectedGoods: Goods?
    fileprivate var selectedMerchant: Merchant?
    fileprivate var listView: ListView!
    fileprivate var theSort: Int = 1
    fileprivate var currentPage: Int = 1
    fileprivate var merchantsArray: [Merchant] = [] {
        didSet {
            brandsTableView.reloadData()
        }
    }
    fileprivate lazy var noneView: NoneView = { return NoneView(frame: self.brandsTableView.bounds, type: .other)}()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        setListView()
        setTaleView()
        requestList()
        addPullToRefresh()
    }
    
    deinit {
        if let tableView = brandsTableView {
            if let topRefresh = tableView.topPullToRefresh {
                tableView.removePullToRefresh(topRefresh)
            }
            if let bottomRefresh = tableView.bottomPullToRefresh {
                tableView.removePullToRefresh(bottomRefresh)
            }
        }
    }
    
    fileprivate func addPullToRefresh() {
        let topRefresh = TopPullToRefresh()
        let bottomRefresh = PullToRefresh(position: .bottom)
        brandsTableView?.addPullToRefresh(bottomRefresh) { [weak self] (tableView) -> Void in
            self?.requestList((self?.currentPage ?? 1) + 1)
            self?.brandsTableView?.endRefreshing(at: .bottom)
        }
        brandsTableView?.addPullToRefresh(topRefresh) { [weak self] in
            self?.requestList()
        }
    }

    fileprivate func setTaleView() {
        brandsTableView.register(R.nib.brandTableViewCell)
//        brandsTableView.rowHeight = UITableViewAutomaticDimension
        brandsTableView.configBackgroundView()
        brandsTableView.tableFooterView = UIView()
    }
    
    fileprivate func setListView() {
        let listTitleArray = [R.string.localizable.string_title_default()]
        let sortArray = GoodsSort.setBrandZoneSort()
        listView = ListView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40), titleArray: listTitleArray)
        listView.createDataSource([], secondDatas: [], thirdDatas: sortArray, firstIsCat: false)
        view.addSubview(listView)
        listView.selectedSortHandleBlock = { [weak self] sort in
            if let sort = sort.sortID, let sortID = Int(sort) {
                self?.theSort = sortID
            }
            self?.requestList()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GoodsDetailViewController {
            vc.goodsID = self.selectedGoods?.goodsID
        }
        if let vc = segue.destination as? BrandDetailViewController {
            vc.merchantID = selectedMerchant?.merchantID
        }
    }
    
}

// MARK: Request
extension MoreBrandsViewController {
    
    func requestList(_ page: Int = 1) {
        MBProgressHUD.loading(view: view)
        let param = GoodsParameter()
        param.page = page
        param.perPage = 10
        param.sort = theSort
        let req: Promise<MerchantListData> = handleRequest(Router.endpoint( GoodsPath.merchantList, param: param), needToken: .default)
        req.then { (value) -> Void in
            if value.isValid {
                if let items = value.data?.items {
                    self.currentPage = page
                    if self.currentPage == 1 {
                        self.merchantsArray = items
                    } else {
                        self.merchantsArray.append(contentsOf: items)
                    }
                }
            }
            if self.merchantsArray.isEmpty {
                self.brandsTableView.tableFooterView = self.noneView
            } else {
                self.brandsTableView.tableFooterView = UIView()
            }
            }.always {
                self.brandsTableView?.endRefreshing(at: .top)
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }

}

// MARK: UITableViewDataSource
extension MoreBrandsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return merchantsArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.brandTableViewCell, for: indexPath) else {
            return UITableViewCell()
        }
        cell.configInfo(merchantsArray[indexPath.section])
        cell.brandDetailHandleBlock = {
            (segueID, merchant) in
            self.selectedMerchant = merchant
            self.performSegue(withIdentifier: segueID, sender: nil)
        }
        cell.goodsDetailHandleBlcok = {(segueID, goods) in
            self.selectedGoods = goods
            self.performSegue(withIdentifier: segueID, sender: nil)
        }
        cell.openDiscountHandleBlock = { [weak self] merchantID in
            guard let vc = R.storyboard.discount.discountViewController() else {
                return
            }
            vc.merchantID = merchantID
            vc.dismissHandleBlock = {
                vc.dismiss(animated: true, completion: nil)
                self?.dim(.out)
            }
            self?.dim(.in)
            self?.present(vc, animated: true, completion: nil)

        }
        return cell
    }
}

// MARK: UITableViewDelegate
extension MoreBrandsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let merchant = merchantsArray[indexPath.section]
        let isDiscount =  merchant.privilegeList?.contains(where: { return $0.type == .discount })
        let isFullCut = merchant.privilegeList?.contains(where: { return $0.type == .fullCut })
        var count: CGFloat = 0
        if isDiscount == true && isFullCut == true {
            count = 2
        } else if isDiscount == true || isFullCut == true {
            count = 1
        } else {
            count = 0
        }
        return 210 + count * 30
    }
    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
    
}

//
//  ShopDetailViewController.swift
//  Bank
//
//  Created by yang on 16/2/24.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD

class ShopDetailViewController: UIViewController {

    @IBOutlet weak fileprivate var sourceLabel: UILabel!
    @IBOutlet weak fileprivate var createdLabel: UILabel!
    @IBOutlet weak fileprivate var nameLabel: UILabel!
    @IBOutlet weak fileprivate var logoImageView: UIImageView!
    @IBOutlet fileprivate var headerView: UIView!
    @IBOutlet weak fileprivate var shopDetailTableView: UITableView!
    var merchantID: String?
    fileprivate var isOpen: [Bool] = [true, true, true]
    fileprivate var merchant: Merchant? {
        didSet {
            setHeaderView()
            shopDetailTableView.reloadData()
        }
    }
    fileprivate var storeArray: [Store] = []
    fileprivate var imageURLArray: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shopDetailTableView.tableHeaderView = headerView
        shopDetailTableView.tableFooterView = UIView()
        shopDetailTableView.rowHeight = UITableViewAutomaticDimension
        shopDetailTableView.register(R.nib.shopAddressTableViewCell)
        shopDetailTableView.register(R.nib.shopDetailTableViewCell)
        shopDetailTableView.register(R.nib.shopAuthTableViewCell)
        shopDetailTableView.register(R.nib.shopDetailSectionHeaderView(), forHeaderFooterViewReuseIdentifier: R.nib.shopDetailSectionHeaderView.name)
        shopDetailTableView.configBackgroundView()
        requestData()
    }
    
    /**
     请求店铺详情的数据
     */
    fileprivate func requestData() {
        let param = GoodsParameter()
        param.merchantID = merchantID
        let req: Promise<MerchantData> = handleRequest(Router.endpoint( GoodsPath.storeInfo, param: param), needToken: .default)
        req.then { (value) -> Void in
            if value.isValid {
                if let items = value.data?.storeList {
                    self.storeArray = items
                }
                self.merchant = value.data
            }
        }.catch { (error) in
            if let err = error as? AppError {
                MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
            }
        }
    }
    
    fileprivate func setHeaderView() {
        
        logoImageView.setImage(with: merchant?.logo, placeholderImage: R.image.image_default_midden())
        if let name = merchant?.name {
            nameLabel.text = name
        }
        if let create = merchant?.created {
            createdLabel.text = R.string.localizable.label_title_star_shop_time() + create.toString("yyyy-MM-dd")
        }
        if let source = merchant?.score {
            sourceLabel.attributedText = NSAttributedString(leftString: R.string.localizable.label_title_star_shop_grade(), rightString: "\(source)分", leftColor: UIColor.darkGray, rightColor: UIColor.orange, leftFontSize: 14, rightFoneSize: 14)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - UITableViewDataSource
extension ShopDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell: ShopAddressTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.shopAddressTableViewCell, for: indexPath) else {
                return UITableViewCell()
            }
            cell.configInfo(storeArray[indexPath.row])
            cell.phoneButton.setImage(R.image.mall_brandZone_btn_shop_call(), for: .normal)
            cell.telHandleBlock = { [weak self] tel in
                self?.setTelAlertViewController(tel)
            }
            return cell
        } else if indexPath.section == 1 {
            guard let cell: ShopDetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.shopDetailTableViewCell, for: indexPath) else {
                return UITableViewCell()
            }
            cell.describeLabel.text = merchant?.detail
            return cell
        } else {
            guard let cell: ShopAuthTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.shopAuthTableViewCell, for: indexPath) else {
                return UITableViewCell()
            }
            if let images = merchant?.attachImages {
                imageURLArray = images
            }
            cell.configInfo(imageURLArray)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isOpen[section] == true {
            if section == 0 {
                return storeArray.count
            } else {
                return 1
            }
        } else {
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
}

// MARK: - UITableViewDelegate
extension ShopDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 70
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: R.nib.shopDetailSectionHeaderView.name) as? ShopDetailSectionHeaderView else {
            return UIView()
        }
        if section == 0 {
            header.sectionImage = R.image.mall_brandZone_icon_shop_address()
            header.sectionTitle = "店铺地址"
            header.isOpen = self.isOpen[section]
            header.openOrCloseHandleBlock = { sender in
                self.isOpen[section] = !self.isOpen[section]
                tableView.reloadSections(IndexSet(integer: section), with: .fade)
            }
            return header
            
        } else if section == 1 {
            header.sectionTitle = "店铺介绍"
            header.sectionImage = R.image.mall_brandZone_icon_shop_detail()
            header.isOpen = self.isOpen[section]
            header.openOrCloseHandleBlock = { sender in
                self.isOpen[section] = !self.isOpen[section]
                tableView.reloadSections(IndexSet(integer: section), with: .fade)
            }
            return header
        } else {
            header.sectionTitle = "认证信息"
            header.sectionImage = R.image.mall_brandZone_ic_shop_info()
            header.isOpen = self.isOpen[section]
            header.openOrCloseHandleBlock = { sender in
                self.isOpen[section] = !self.isOpen[section]
                tableView.reloadSections(IndexSet(integer: section), with: .fade)
            }
            return header
        }
        
    }
}

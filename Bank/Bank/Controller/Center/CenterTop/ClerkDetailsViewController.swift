//
//  ClerkDetailsViewController.swift
//  Bank
//
//  Created by 糖otk on 2017/1/11.
//  Copyright © 2017年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import PullToRefresh
import MBProgressHUD

typealias BackBlock = () -> Void
class ClerkDetailsViewController: BaseViewController {
    
    fileprivate var myStore: MyStore?
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var describeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var headerView: UIView!
    var isSourceHome = true
    var block: BackBlock?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.configBackgroundView()
        headerView.frame = tableView.bounds
        tableView.tableFooterView = headerView
        setupUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        requestMyShopData()
    }
    
    func setupUI() {
        iconImageView.layer.cornerRadius = 50
        iconImageView.layer.masksToBounds = true
        iconImageView.layer.borderWidth = 2
        iconImageView.layer.borderColor = UIColor(hex: 0xC7E7F8).cgColor
        title = "我是店员"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "打赏记录", style: .done, target: self, action: #selector(self.exceptionalRecordAction))
    }
    
    func exceptionalRecordAction() {
        let vc = ExceptionalRecordViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func clickRemoveBindAction(_ sender: Any) {
        let alert = UIAlertController(title: R.string.localizable.alertTitle_tip(), message: R.string.localizable.alertTitle_myshop_unwrap(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_confirm(), style: .default, handler: { [weak self] (action) in
            self?.requestUnwrapData()
        }))
        present(alert, animated: true, completion: nil)
    }
}

extension ClerkDetailsViewController {
    
    /// 请求店员解绑
    fileprivate func requestUnwrapData() {
        MBProgressHUD.loading(view: view)
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( UserPath.unwrap, param: nil))
        req.then { (value) -> Void in
            if self.isSourceHome == false {
                guard let block = self.block else {return}
                block()
            }
            _ = self.navigationController?.popViewController(animated: true)

            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    /// 请求我的店铺数据
    fileprivate func requestMyShopData(page: Int = 1) {
        let param = UserParameter()
        param.page = page
        param.perPage = 20
        MBProgressHUD.loading(view: view)
        let req: Promise<MyShopData> = handleRequest(Router.endpoint( UserPath.myStore, param: param))
        req.then { (value) -> Void in
            self.myStore = value.data
            self.setClerkDetails(myStore: self.myStore)
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    fileprivate func setClerkDetails(myStore: MyStore?) {
        iconImageView.setImage(with: myStore?.storeLogo, placeholderImage: R.image.image_default_small())
        nameLabel.text = myStore?.storeName
        describeLabel.text = myStore?.storeDetail
    }
    
}

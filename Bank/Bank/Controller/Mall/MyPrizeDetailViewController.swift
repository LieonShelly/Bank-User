//
//  MyPrizeDetailViewController.swift
//  Bank
//
//  Created by yang on 16/7/4.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import URLNavigator
import PromiseKit
import MBProgressHUD

class MyPrizeDetailViewController: BaseViewController {

    @IBOutlet weak fileprivate var prizeView: UIView!
    @IBOutlet weak fileprivate var coverImageView: UIImageView!
    @IBOutlet weak fileprivate var prizeTitleLabel: UILabel!
    @IBOutlet weak fileprivate var prizeMaskLabel: UILabel!
    @IBOutlet weak fileprivate var prizePriceLabel: UILabel!
    @IBOutlet weak fileprivate var dateLabel: UILabel!
    @IBOutlet weak fileprivate var codeImageView: UIImageView!
    @IBOutlet weak fileprivate var codeLabel: UILabel!
    @IBOutlet weak fileprivate var invalidLabel: UILabel!
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var userListID: String?
    fileprivate var prize: Prize?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.configBackgroundView()
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        prizeView.addGestureRecognizer(tap)
        requestData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PrizeDetailViewController {
            vc.giftID = self.prize?.prizeID
        }
    }
    
    /// 点击奖品跳转奖品详情页
    ///
    /// - Parameter tap: 单击事件
    func tapAction(_ tap: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: R.segue.myPrizeDetailViewController.showPrizeDetailVC, sender: nil)
    }
    
    /// 设置UI
    fileprivate func configUI() {
        coverImageView.setImage(with: prize?.cover, placeholderImage: R.image.image_default_midden())
        prizeTitleLabel.text = prize?.title
        prizeMaskLabel.text = prize?.summary
        if let price = prize?.marketPrice?.numberToString() {
            prizePriceLabel.text = "市场参考价：\(price)元"
        }
        if let date = prize?.expireTime?.toString("yyyy-MM-dd") {
            dateLabel.text = "兑奖有效期至\(date)"
        }
        if let code = prize?.code {
            codeLabel.text = code.couponString()
        }
        if let string = prize?.qrcodeData {
            if let data = Data(base64Encoded: string, options: .ignoreUnknownCharacters) {
                codeImageView.image = UIImage(data: data)
            }
        }
        if let status = prize?.status {
            switch status {
            case .cashed, .outOfTime:
                codeImageView.alpha = 0.1
                codeLabel.alpha = 0.1
                invalidLabel.isHidden = false
            case .unCash:
                codeImageView.alpha = 1
                codeLabel.alpha = 1
                invalidLabel.isHidden = true
            }
        }
    }
    
    /// 请求我的奖品详情
    fileprivate func requestData() {
        let param = GiftParameter()
        if let userListID = self.userListID {
            param.userListID = Int(userListID)
        }
        MBProgressHUD.loading(view: view)
        let req: Promise<PrizeDetailData> = handleRequest(Router.endpoint( GiftPath.myGiftDetail, param: param))
        req.then { [weak self] (value) -> Void in
            self?.prize = value.data
            self?.configUI()
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

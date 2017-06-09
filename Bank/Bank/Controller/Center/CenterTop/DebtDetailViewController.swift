//
//  DebtDetailViewController.swift
//  Bank
//
//  Created by Koh Ryu on 11/30/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD

class DebtDetailViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var imageView: UIImageView!
    @IBOutlet fileprivate weak var nameLabel: UILabel!
    @IBOutlet fileprivate weak var billLabel: UILabel!
    @IBOutlet fileprivate weak var timeLabeL: UILabel!
    @IBOutlet fileprivate weak var restLabel: UILabel!
    @IBOutlet fileprivate weak var contentView: UIView!
    @IBOutlet fileprivate weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var tableHeaderView: UIView!
    
    fileprivate var selectedAction: DetailActionType?
    
    var creditGoodDetails: [CreditGoodDetail] = []
    var starTimeString = ""
    var endTimeString = ""
    var goodID: String?
    var creditGood: CreditGoods?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.configBackgroundView()
        tableView.tableHeaderView = tableHeaderView
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupDebtDetalData()
        requestData()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension DebtDetailViewController {
    
    /**
     请求还款商品明细
     */
    func requestData() {
        let param = GoodsParameter()
        param.goodsID = self.goodID
        let req: Promise<CreditGoodsData> = handleRequest(Router.endpoint(EAccountPath.creditGoodsInfo, param: param))
        req.then { (value) -> Void in
            if value.isValid {
                /* if let items = value.data?.items where !itemns.isEmpty {
                 self.loadDatas(items)
                 }*/
                guard let creditGoodDetails = value.data?.searchButtons, !creditGoodDetails.isEmpty else {return}
                self.creditGoodDetails = creditGoodDetails
            }
            }.always {
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    /**
     设置基本数据
     */
    func setupDebtDetalData() {
        
        timeLabeL.text = creditGood?.endTime?.toDateString()
        nameLabel.text = creditGood?.title
        if let creditGood = creditGood {
            billLabel.amountWithUnit(creditGood.total, color: UIColor.white, amountFontSize: 13, unitFontSize: 13, strikethrough: false, fontWeight: UIFontWeightRegular, unit: "元", decimalPlace: 2, useBigUnit: false)
            restLabel.amountWithUnit(creditGood.remain, color: UIColor.white, amountFontSize: 22, unitFontSize: 13, strikethrough: false, fontWeight: UIFontWeightRegular, unit: "元", decimalPlace: 2, useBigUnit: false)
            imageView.setImage(with: creditGood.imageURL, placeholderImage: R.image.image_default_midden())
        }
    }
}

extension DebtDetailViewController {
    
    @IBAction func queryTime(_ sender: UIButton) {
        switch sender.tag {
        case 0, 1, 2:
            let goodDetail: CreditGoodDetail = creditGoodDetails[sender.tag]
            starTimeString = goodDetail.start
            endTimeString = goodDetail.end
            self.selectedAction = DetailActionType(rawValue: sender.tag)
        case 3:
            starTimeString = ""
            endTimeString = ""
        default:
            break
        }
        performSegue(withIdentifier: R.segue.debtDetailViewController.showRecordFilterVC, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RecordFilterViewController {
            vc.filterType = selectedAction
            vc.dataType = .debt
            vc.title = R.string.localizable.controller_title_repayment_details()
        }
        
    }

}

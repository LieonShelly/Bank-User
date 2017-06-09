//
//  AccountDateilsViewController.swift
//  Bank
//
//  Created by Mac on 15/11/23.
//  Copyright © 2015年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit
import URLNavigator
import MBProgressHUD

class AccountDatailViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var logoImageView: UIImageView!
    @IBOutlet fileprivate weak var bankNameLabel: UILabel!
    @IBOutlet fileprivate weak var numberLabel: UILabel!
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    var card: BankCard?
    
    fileprivate var infoArray: [(String, String, Bool)] = []
    fileprivate var actionTitles: [String] = []
    fileprivate var selectedAction: DetailActionType?
    fileprivate var payPass: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(R.nib.accountInfoTableViewCell)
        tableView.register(R.nib.accountActionTableViewCell)
        tableView.tableFooterView = UIView()
        tableView.configBackgroundView()
        configCard(card)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configCard(_ card: BankCard?) {
        if card?.bankID == .mccb {
            infoArray = [("账户余额", "281934.00元", true), ("可用余额", "281934.00元", true),
                         ("储种", "活期储蓄存款", false),
                         ("币种", "人民币", false), ("开户行", "绵阳市经开区网点", false)]
            actionTitles = ["七日明细", "本月明细", "三个月明细", "明细查询", "我要转账", "我要理财"]
        } else {
            infoArray = [("储种", "活期储蓄存款", false)]
            actionTitles = ["七日明细", "本月明细", "三个月明细", "明细查询", "我要理财", ""]
        }
        logoImageView.setImageWithURL(card?.bankLogo,
                                         placeholderImage: R.image.image_default_small())
        bankNameLabel.text = card?.bankName
        numberLabel.text = card?.number
        tableView.reloadData()
    }
    
    func requestDetail() {
        let param = BankCardParameter()
        param.cardID = card?.cardID
        let req: Promise<BankCardDetailData> = handleRequest(Router.endpoint(endpoint: BankCardPath.detail, param: param))
        req.then { (value) -> Void in
            if let data = value.data {
                self.card = data
            }
            }.catch { _ in }
    }
    
    func requestUnbind() {
        let param = BankCardParameter()
        param.cardID = card?.cardID
        param.payPass = payPass
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint(endpoint: BankCardPath.unbind, param: param))
        req.then { (_) -> Void in
            self.performSegue(withIdentifier: R.segue.accountDatailViewController.showCardsListVC, sender: nil)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
            }
    }
    
    fileprivate func dismissVerifyVC(_ result: VerifyPayPassResult) {
        dim(.out, coverNavigationBar: true)
        dismiss(animated: true) { [weak self] in
            switch result {
            case .passed:
                self?.requestUnbind()
            case .failed:
                self?.setFundPassAlertController()
            default:
                break
            }
        }
    }
    
    @IBAction func moreHandle() {
        let action = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        action.addAction(UIAlertAction(title: R.string.localizable.alertTitle_remove_binding(), style: .destructive, handler: { (_) in
            let req: Promise<NullDataResponse> = handleRequest(Router.endpoint(endpoint: UserPath.payPassStatus, param: nil))
            req.then { (_) -> Void in
                guard let vc = R.storyboard.main.verifyPayPassViewController() else { return }
                vc.resultHandle = { [weak self] (result, pass) in
                    self?.payPass = pass
                    self?.dismissVerifyVC(result)
                }
                self.dim(.in, coverNavigationBar: true)
                self.present(vc, animated: true, completion: nil)
            }.catch { (error) in
                guard let err = error as? AppError else {
                    return
                }
                if err.errorCode.errorCode() == RequestErrorCode.payPassLock.errorCode() {
                    self.setFundPassAlertController(message: err.toError().localizedDescription)
                } else {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }

            }
        }))
        action.addAction(UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: .cancel, handler: nil))
        present(action, animated: true, completion: nil)
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.segue.accountDatailViewController.showFilterVC.identifier {
            guard let vc = segue.destination as? RecordFilterViewController else {
                return
            }
            vc.filterType = selectedAction
            vc.cardID = card?.cardID
            vc.title = R.string.localizable.controller_title_bankcard_detail()
        }
    }

}

extension AccountDatailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == infoArray.count {
            return 150
        } else {
            return 50
        }
    }
}

extension AccountDatailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if card?.bankID == .mccb {
            return infoArray.count + 1
        } else {
            return infoArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < infoArray.count {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.accountInfoTableViewCell, for: indexPath) else {
                return UITableViewCell()
            }
            let info = infoArray[indexPath.row]
            cell.configInfo(info)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.accountActionTableViewCell, for: indexPath) else {
                return UITableViewCell()
            }
            cell.configButtons(actionTitles)
            cell.buttonBlock = { (action) in
                switch action {
                case .filter3Month, .filterWeek, .filterMonth, .filterCustom:
                    self.selectedAction = action
                    self.performSegue(withIdentifier: R.segue.accountDatailViewController.showFilterVC, sender: nil)
                case .finance:
                    break
                case .trans:
                    break
                }
            }
            return cell
        }
    }
}

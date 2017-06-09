//
//  CashPayViewController.swift
//  Bank
//
//  Created by Tzzzzz on 16/8/16.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit
import URLNavigator
import Kingfisher
import MBProgressHUD

class CashPayViewController: BaseViewController {
//    private var price: Float = 0

    fileprivate var param: UserParameter = UserParameter()
//    private var orderParam: OrderParameter = OrderParameter()

    var submitType: SubmitType?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak fileprivate var payMoneyTextField: UITextField!
    @IBOutlet var headerView: UIView!
 
    override func viewDidLoad() {
        title = R.string.localizable.controller_title_money_repayment()
        tableView.configBackgroundView()
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
    }
}
extension CashPayViewController {
    
    /// 确认还款
    @IBAction func cashPayMoney(_ sender: UIButton) {
        payMoneyTextField.resignFirstResponder()
//        showPayment()
        requestBankCardData()
    }
    
    /**
     选择支付界面
     */
//    fileprivate func showPayment() {
//        guard let paymentvc = R.storyboard.main.choosePaymentViewController() else {
//            return
//        }
//        guard let amountString = payMoneyTextField.text else {return}
//        guard let amount = Double(amountString) else {return}
//        paymentvc.amount = amount
//        paymentvc.addNewCard = { [weak self] in
//            guard let vc = R.storyboard.bank.cardsListViewController() else {
//                return
//            }
//            vc.lastViewController = self
//            self?.navigationController?.pushViewController(vc, animated: true)
//        }
//        paymentvc.dismiss = { [weak self] in
//            self?.dim(.out, coverNavigationBar: true)
//            paymentvc.dismiss(animated: true, completion: nil)
//        }
//        paymentvc.confirm = { [weak self] bankcard in
//            self?.param.cardID = bankcard?.cardID
//            self?.requestPayPassData()
//        }
//        dim(.in, coverNavigationBar: true)
//        self.present(paymentvc, animated: true, completion: nil)
//        
//    }
    
    /// 请求银行卡信息
    func requestBankCardData() {
        let parameter = BankCardParameter()
        parameter.bankType = .all
        let hud = MBProgressHUD.loading(view: view)
        let req: Promise<BankCardListData> = handleRequest(Router.endpoint( BankCardPath.list, param: parameter))
        req.then { (value) -> Void in
            if let items = value.data?.cardList, !items.isEmpty {
                self.requestPayPassData(cardID: items.first?.cardID)
            } else {
                self.showBindCardAlert()
            }
            }.always {
                hud.hide(animated: true)
            }.catch { (error) in
                if let window = UIApplication.shared.keyWindow {
                    MBProgressHUD.errorMessage(view: window, message: error.localizedDescription)
                }
        }
    }

    /**
     请求输入支付密码界面
     */
    fileprivate func requestPayPassData(cardID: String?) {
        let hud = MBProgressHUD.loading(view: view)
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( UserPath.payPassStatus, param: nil))
        req.then { (value) -> Void in
            guard let vc = R.storyboard.main.verifyPayPassViewController() else { return }
            vc.type = .moneyRepay
            vc.cardID = cardID
            vc.money = self.payMoneyTextField.text
            vc.resultHandle = { [weak self] (result, pass) in
            switch result {
                case .passed:
                    self?.dim(.out, coverNavigationBar: true)
                    vc.dismiss(animated: true, completion: nil)
                    self?.showPaySuccess()
                case .canceled:
                    self?.dim(.out, coverNavigationBar: true)
                    vc.dismiss(animated: true, completion: nil)
                case .failed:
                    self?.dim(.out, coverNavigationBar: true)
                    vc.dismiss(animated: true, completion: nil)
                    self?.setFundPassAlertController()
                    break
                }
            }
            self.dim(.in, coverNavigationBar: true)
            self.present(vc, animated: true, completion: nil)
            }.always {
                hud.hide(animated: true)
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
        
    }
    
    /// 支付成功
    fileprivate func showPaySuccess() {
        guard let vc = R.storyboard.main.paySuccessViewController() else {
            return
        }
        vc.dismissHandleBlock = {
            self.dim(.out, coverNavigationBar: true)
            vc.dismiss(animated: true, completion: nil)
            _ = self.navigationController?.popViewController(animated: true)
        }
        self.dim(.in, coverNavigationBar: true)
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func unwindPayFromBindCard(_ segue: UIStoryboardSegue) {
        
    }
    
}

//extension CashPayViewController: ChooseCardProtocol {
//    func dismissFromAddNewCard() {
//        _ = self.navigationController?.popToViewController(self, animated: true)
//        DispatchQueue.main.async {
//            self.showPayment()
//        }
//    }
//}

//
//  DiscountBillTableViewController.swift
//  Bank
//
//  Created by 杨锐 on 2016/10/12.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD

class DiscountBillTableViewController: BaseTableViewController {
    
    @IBOutlet weak var orderPriceLabel: UILabel!
    @IBOutlet weak var outPriceLabel: UILabel!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var discountTypeLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var ruleLabel: UILabel!
    @IBOutlet weak var discountPriceLabel: UILabel!
    @IBOutlet weak var actualPriceLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var openButton: UIButton!
    
    var discount: Discount?
    fileprivate var param: DiscountParameter = DiscountParameter()
    fileprivate var labelHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        tableView.configBackgroundView()
        configInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return 1
        }
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 16
        }
        return 10
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 0 {
            return (discount ?? Discount()).type == DiscountType.none ? 0 : 120 + labelHeight
        }
        return 50
    }
    
    @IBAction func openAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            ruleLabel.numberOfLines = 0
            ruleLabel.font = UIFont.systemFont(ofSize: 14)
            sender.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 14)]
            let size = CGSize(width: screenWidth - 110 - 60, height: 500)
            if let string = ruleLabel.text {
                let str = NSString(string: string)
                let rect = str.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
                labelHeight = rect.height - 17
            }
        } else {
            ruleLabel.numberOfLines = 1
            sender.transform = CGAffineTransform(rotationAngle: CGFloat(0))
            labelHeight = 0
        }
        tableView.reloadData()
    }
    
    /// 设置数据
    fileprivate func configInfo() {
        title = discount?.merchantName ?? ""
        guard let orderPrice = discount?.total else {
            return
        }
        orderPriceLabel.text = (orderPrice).numberToString() + "元"

        if let outPrice = discount?.outSum {
            outPriceLabel.text = (outPrice).numberToString() +  "元"
        }
        eventNameLabel.text = discount?.privilegeName
        discountTypeLabel.text = discount?.type?.title
        if discount?.type == .discount {
            if let discount = discount?.discount {
                discountLabel.attributedText = "\(discount)".getAttString()
            }
        } else if discount?.type == .fullCut {
            if let full = discount?.fullSum, let min = discount?.minusSum {
                discountLabel.text = "满\(full.numberToString())减\(min.numberToString())"
            }
        }
        if let topPrivilege = discount?.topPrivilege {
            desLabel.text = "优惠限额:最高减\(topPrivilege.numberToString())元"
        }
        
        guard let actualPrice = discount?.actual else {
            return
        }
        actualPriceLabel.text = actualPrice.numberToString() + "元"
        confirmButton.setTitle("确认买单"+actualPrice.numberToString() + "元", for: .normal)
        discountPriceLabel.text =  (discount ?? Discount()).type == DiscountType.none ? "0元" : "-" +  (orderPrice - actualPrice).numberToString() + "元"
        ruleLabel.text = discount?.rule
    }
    
    /// 确认买单
    @IBAction func confirmAction(_ sender: UIButton) {
        if discount?.actual == 0 {
            Navigator.showAlertWithoutAction(nil, message: R.string.localizable.alertTtile_no_pay())
            return 
        }
//        showPayment()
        requestBankCardData()
    }
    
    /**
     选择支付界面
     */
//    fileprivate func showPayment() {
////        if let orderID = discount?.orderID {
////            param.orderId = Int(orderID)
////        }
//        guard let paymentvc = R.storyboard.main.choosePaymentViewController() else {
//            return
//        }
//        if let amount = discount?.actual {
//            paymentvc.amount = amount
//        }
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
//            self?.requestPayPassData(cardID: bankcard?.cardID)
//        }
//        dim(.in, coverNavigationBar: true)
//        self.present(paymentvc, animated: true, completion: nil)
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
    func requestPayPassData(cardID: String?) {
        let hud = MBProgressHUD.loading(view: view)
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( UserPath.payPassStatus, param: nil))
        req.then { (value) -> Void in
            guard let vc = R.storyboard.main.verifyPayPassViewController() else { return }
            vc.type = .privilegePay
            vc.cardID = cardID
            vc.orderID = self.discount?.orderID
            vc.resultHandle = { [weak self] (result, pass) in
                
                switch result {
                case .passed:
                    self?.dim(.out, coverNavigationBar: true)
                    vc.dismiss(animated: true, completion: nil)
                    self?.showPaySuccess()
                case .failed:
                    self?.dim(.out, coverNavigationBar: true)
                    vc.dismiss(animated: true, completion: nil)
                    self?.setFundPassAlertController()
                default:
                    self?.dim(.out, coverNavigationBar: true)
                    vc.dismiss(animated: true, completion: nil)
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
        guard let vc = R.storyboard.main.paySuccessViewController(), let vcc = R.storyboard.discount.discountListViewController() else {
            return
        }
        vcc.pushSourceIsPay = true
        vc.dismissHandleBlock = {
            self.dim(.out, coverNavigationBar: true)
            vc.dismiss(animated: true, completion: nil)
            self.navigationController?.pushViewController(vcc, animated: true)
        }
        self.dim(.in, coverNavigationBar: true)
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func unwindPayFromBindCard(_ segue: UIStoryboardSegue) {
        
    }

}

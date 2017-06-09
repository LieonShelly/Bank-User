//
//  integralPayController.swift
//  
//
//  Created by Tzzzzz on 16/8/16.
//
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD

class IntegralPayController: BaseViewController {
   
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet fileprivate weak var determinButton: UIButton!
    @IBOutlet fileprivate weak var paymentLabel: UILabel!
    @IBOutlet fileprivate weak var currentIntegralLabel: UILabel!
    @IBOutlet fileprivate weak var integralTextField: UITextField!
    @IBOutlet var headerView: UIView!
    
    var importIntegral: Int = 0
    var currentIntegral: Int = 0
    
    override func viewDidLoad() {
        tableView.configBackgroundView()
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        title = R.string.localizable.controller_title_integral_repayment()
        integralTextField.addTarget(self, action: #selector(self.updateTextFiedlText), for: .editingChanged)
        paymentLabel.text = "0"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestPointData()
    }
    
    func updateTextFiedlText() {
        guard let importIntegralString = integralTextField.text else {return}
        guard let currentIntegralString = currentIntegralLabel.text else {return}
        self.captionLabel.text = R.string.localizable.label_title_100_integer()
        self.determinButton.isEnabled = false
        guard importIntegralString.characters.isEmpty == false else {
            self.captionLabel.isHidden = true
            return
        }
        guard (importIntegralString.contains(".") == false ) || (importIntegralString.contains("-") == false) else {
            self.captionLabel.isHidden = false
            return
        }
        guard let currentIntegral = Int(currentIntegralString) else {return}
        guard let importIntegral = Int(importIntegralString) else {
            self.captionLabel.isHidden = false
            return
        }
        paymentLabel.text = String(importIntegral/100)
        guard (importIntegral % 100 == 0) && (importIntegral >= 1000) else {
            self.captionLabel.isHidden = false
            return
        }
        guard importIntegral < currentIntegral else {
            self.captionLabel.text = R.string.localizable.label_title_integral_excess()
            self.captionLabel.isHidden = false
            return
        }
        self.captionLabel.isHidden = true
        self.determinButton.isEnabled = true
        self.importIntegral = importIntegral
    }
    
    @IBAction func clickConfirmPaymentButton(_ sender: UIButton) {
        view.endEditing(true)
        integralRepayHandle(self.importIntegral)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        view.endEditing(true)
    }
    @IBAction func intergralExplainAction(_ sender: Any) {
        guard let helpVC = R.storyboard.center.helpCenterHomeViewController() else {return}
        helpVC.tag = HelpCenterTag.exchange
        Navigator.push(helpVC)
    }
}

extension IntegralPayController {

    /**
     确认还款
     */
    func integralRepayHandle(_ integral: Int) {
        guard integral != 0 else {return}
        MBProgressHUD.loading(view: view)
        let param = UserParameter()
        param.integral = integral
        let req: Promise<GetPointData> = handleRequest(Router.endpoint( UserPath.intergralRepay, param: param))
        req.then { (value) -> Void in
            self.currentIntegralLabel.text = value.data?.userPoint
            self.showAlertTitle()
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    /**
     获取当前积分
     */
    func requestPointData() {
        let req: Promise<GetPointData> = handleRequest(Router.endpoint( UserPath.totalPoint, param: nil))
        req.then { (value) -> Void in
            if let result = value.data?.totalPoint {
                self.currentIntegralLabel.text = String(result)
            }
            }.always {
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
}

extension IntegralPayController {
    func showAlertTitle() {
        let alertController = UIAlertController(title: R.string.localizable.alertTitle_integral_pay_success(), message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: R.string.localizable.alertTitle_okay(), style: .default, handler: { (UIAlertAction) in

        })
        alertController.addAction(okAction)
        Navigator.present(alertController)
    }
}

//
//  ExchangeViewController.swift
//  Bank
//
//  Created by Mac on 15/11/26.
//  Copyright © 2015年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD

class ExchangeViewController: BaseViewController {

    @IBOutlet fileprivate weak var totalPointLabel: UILabel!
    @IBOutlet fileprivate weak var exchangeNumberTextField: UITextField!
    @IBOutlet fileprivate weak var moneyLabel: UILabel!
    @IBOutlet fileprivate weak var warnningLabel: UILabel!
    @IBOutlet fileprivate weak var determinButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var headerView: UIView!
    
    var totalPoint: Int = 0
    
    fileprivate var pointRate: PointRate?
    fileprivate var isRedeemPoint: IsRedeemPoint?
    fileprivate lazy var exchangeParam: MallParameter = {
        return MallParameter()
    }()
    fileprivate let rate = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.configBackgroundView()
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        warnningLabel.isHidden = true
        totalPointLabel.text = String(totalPoint)
        moneyLabel.text = String(0)
        exchangeNumberTextField.keyboardType = .numberPad
        exchangeNumberTextField.clearButtonMode = .always
        exchangeNumberTextField.addTarget(self, action: #selector(textfieldChanged), for: .editingChanged)
        requestData()
    }
    
    @objc fileprivate func textfieldChanged() {
        let exchangeIntegralString = exchangeNumberTextField.text ?? "0"
        moneyLabel.text = ""
        guard exchangeIntegralString.characters.isEmpty == false else {
            return
        }
        guard let importIntegral = Int(exchangeIntegralString) else {
            return
        }
        self.determinButton.isEnabled = true
        moneyLabel.text = String(importIntegral/100)
    }
    
    func judgePoint() -> Bool {
        let currentPointString = totalPointLabel.text ?? "0"
        let changePointString = exchangeNumberTextField.text ?? "0"
        let currentPoint = Int(currentPointString) ?? 0
        let changePoint = Int(changePointString) ?? 0
        guard changePointString.characters.isEmpty == false else {
            Navigator.showAlertWithoutAction(nil, message: R.string.localizable.integral_exchangepoint_warningText1())
            return false
        }
        
        guard (changePoint % 100 == 0) && (changePoint >= 1000) else {
            Navigator.showAlertWithoutAction(nil, message: R.string.localizable.integral_exchangepoint_warningText1())
            return false
        }
        
        guard changePoint < currentPoint else {
            Navigator.showAlertWithoutAction(nil, message: R.string.localizable.integral_exchangepoint_warningText2())
            return false
        }
        return true
    }
    
    /**
     请求积分兑换汇率
     */
    fileprivate func requestData() {
        let req: Promise<PointRateData> = handleRequest(Router.endpoint( MallPath.pointExchangeRate, param: nil))
        req.then { (value) -> Void in
            if value.isValid {
                self.pointRate = value.data
            }
        }.catch { (error) in
            if let err = error as? AppError {
                MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
            }
        }
    }

    @IBAction func determineAction(_ sender: UIButton) {
        if !judgePoint() {return}
        MBProgressHUD.loading(view: view)
        //查询可兑换积分
        validInputs().then { (param) -> Promise<IsRedeemPointData> in
            let req: Promise<IsRedeemPointData> = handleRequest(Router.endpoint( MallPath.isRedeemPoint, param: param))
            return req
        }.then { value -> Void in
            self.isRedeemPoint = value.data
            self.isRedeedPoint()
        }.always { 
            MBProgressHUD.hide(for: self.view, animated: true)
        }.catch { (error) in
            if let err = error as? AppError {
                MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
            }
        }
    }
    
    /**
     兑换积分
     */
    fileprivate func requestExchangePoint() {
        MBProgressHUD.loading(view: view)
        if let point = exchangeNumberTextField.text {
            exchangeParam.point = Int(point)
        }
        let req: Promise<PointRedeemData> = handleRequest(Router.endpoint( MallPath.pointExchange, param: exchangeParam))
        req.then { (value) -> Void in
            guard let redeemId = value.data?.redeemId else {return}
            guard let vc = R.storyboard.point.exchangeDetailTableViewController() else {return}
            vc.redeemID = redeemId
            self.navigationController?.pushViewController(vc, animated: true)
        }.always {
            MBProgressHUD.hide(for: self.view, animated: true)
        }.catch { (error) in
            if let err = error as? AppError {
                MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
            }
        }
        
    }
    
    fileprivate func validInputs() -> Promise<MallParameter> {
        return Promise { fulfill, reject in
            let count = exchangeNumberTextField.text?.characters.isEmpty == false
            switch count {
            case true:
                let param = MallParameter()
                if let point = exchangeNumberTextField.text {
                    param.point = Int(point)
                }
                fulfill(param)
            case false:
                let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                reject(error)
            }
        }
    }
    
    fileprivate func isRedeedPoint() {
        if self.isRedeemPoint?.isDebt == true && self.isRedeemPoint?.isRedeem == true {
            showAlertController(self.isRedeemPoint?.message)
        } else if self.isRedeemPoint?.isRedeem == true {
            // show PayPassView
            showVerifyPayPass()
        } else {
            if let point = self.isRedeemPoint?.redeemPoint {
                Navigator.showAlertWithoutAction(nil, message: "当前最大可兑换积分为\(point)积分")
            }
            
        }
    }
    
    fileprivate func showVerifyPayPass() {
        guard let vc = R.storyboard.main.verifyPayPassViewController() else {
            return
        }
        vc.resultHandle = { [weak self] (result, pass) in
            self?.dim(.out, coverNavigationBar: true)
            vc.dismiss(animated: true, completion: nil)
            if result == .passed {
                self?.exchangeParam.payPass = pass
                self?.requestExchangePoint()
            }
        }
        dim(.in, coverNavigationBar: true)
        self.present(vc, animated: true, completion: nil)
    }
    
    fileprivate func showAlertController(_ message: String?) {
        let alert = UIAlertController(title: R.string.localizable.alertTitle_tip(), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_confirm(), style: .default, handler: { (action) in
            self.showVerifyPayPass()
        }))
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func gotoHelpDetailAction(_ sender: UIButton) {
        guard let vc = R.storyboard.center.helpCenterHomeViewController() else {
            return
        }
        vc.tag = HelpCenterTag.exchange
        navigationController?.pushViewController(vc, animated: true)
    }

}

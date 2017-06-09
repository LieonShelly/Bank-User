//
//  ImportExportViewController.swift
//  Bank
//
//  Created by Koh Ryu on 16/5/3.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import Alamofire
import Eureka
import URLNavigator
import PromiseKit

class ImportExportViewController: FormViewController, Dimmable {
    
    @IBOutlet private weak var footerView: UIView!
    @IBOutlet private weak var confirmButton: UIButton!
    @IBOutlet private weak var tipsLabel: UILabel!
    
    var isImport: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isImport {
            title = R.string.localizable.view_title_charge()
        } else {
            title = R.string.localizable.view_title_withdraw()
        }
        tableView?.configBackgroundView()
        setBackBarButton()
        setupTableView()
    }
    
    func setupTableView() {
        footerView.backgroundColor = .colorFromHex(CustomKey.Color.TabBackgroundColor)
        var title1 = R.string.localizable.charge_chooseBank()
        var title2 = R.string.localizable.charge_amount_desc()
        var buttonTitle = R.string.localizable.charge_button_confirm()
        var bottomTips = R.string.localizable.charge_bottom_tips()
        var placeholder = R.string.localizable.charge_amount_placeholder()
        if !isImport {
            title1 = R.string.localizable.withdraw_chooseBank()
            title2 = R.string.localizable.withdraw_amount_desc()
            buttonTitle = R.string.localizable.withdraw_button_confirm()
            bottomTips = R.string.localizable.withdraw_bottom_tips()
            placeholder = R.string.localizable.withdraw_amount_placeholder()
        }
        confirmButton.setTitle(buttonTitle, forState: .Normal)
        tipsLabel.text = bottomTips
        TextRow.defaultCellUpdate = { cell, row in
            cell.height = { return 50 }
            cell.textLabel?.font = .systemFontOfSize(17.0)
            cell.textLabel?.textColor = .colorFromHex(0x666666)
            cell.textField.font = .systemFontOfSize(17.0)
            cell.textField.textAlignment = .Left
        }
        TextRow.defaultRowInitializer = { row in
            row.textFieldLeftConst = 110
        }
        DecimalRow.defaultCellUpdate = { cell, row in
            cell.height = { return 50 }
            cell.textLabel?.font = .systemFontOfSize(17.0)
            cell.textLabel?.textColor = .colorFromHex(0x666666)
            cell.textField.font = .systemFontOfSize(17.0)
            cell.textField.textAlignment = .Left
        }
        DecimalRow.defaultRowInitializer = { row in
            row.textFieldLeftConst = 110
        }
        
        var section: Section = Section()
        if !isImport {
            // TODO: 可提现金额
            section = Section(footer: "  可提现 ¥648.60")
        }
        
        section
            <<< TextRow() {
                $0.title = title1
                }.cellUpdate { (cell, row) in
                    cell.textField.userInteractionEnabled = false
                    if self.isImport {
                        cell.accessoryView = UIImageView(image: R.image.icon_card())
                    } else {
                        cell.accessoryView = UIImageView(image: R.image.btn_payments())
                    }
                }.onCellSelection { (cell, row) in
                    self.showChooseCard()
                    
            }
            <<< DecimalRow() {
                $0.title = title2
                $0.tag = "amount"
                $0.useFormatterDuringInput = true
                $0.placeholder = placeholder
                let formatter = CurrencyFormatter()
                formatter.locale = NSLocale(localeIdentifier: "zh_Hans_CN")
                formatter.numberStyle = .CurrencyStyle
                $0.formatter = formatter
                }.cellUpdate { (cell, row) in
                    let label = UILabel()
                    label.text = "元"
                    label.sizeToFit()
                    cell.accessoryView = label
        }
        
        form +++= section
        tableView?.configBackgroundView()
        tableView?.tableFooterView = footerView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func unwindChargeWithdrawFromChooseCard(segue: UIStoryboardSegue) {
        dim(.Out, coverNavigationBar: true)
    }
    
    internal func showChooseCard() {
        guard let vc = R.storyboard.main.chooseCardViewController() else { return }
        vc.pushMode = false
        vc.dismiss = { card in
            self.dim(.Out, coverNavigationBar: true)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        vc.addNewCard = {
            guard let vc = R.storyboard.bank.bindCardPickViewController() else { return }
            vc.lastViewController = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
        dim(.In, coverNavigationBar: true)
        presentViewController(vc, animated: true, completion: nil)
    }
    
    private func withdrawHandle() {
        guard let amount = form.values()["amount"] as? Double else {
            return
        }
        let param = InvestParameter()
        // 绑定的绵商行银行卡
        param.bankID = ""
        param.amount = Float(amount)
        let req: Promise<NullDataResponse> = handleRequest(Router.Endpoint(endpoint: EAccountPath.Withdraw, param: param))
        req.then { (value) -> Void in
            // success
        }.error { (error) in
            if let err = error as? AppError {
                Navigator.showAlertWithoutAction(nil, message: err.toError().localizedDescription)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }

    private func chargeHandle() {
        guard let amount = form.values()["amount"] as? Double else {
            return
        }
        let param = InvestParameter()
        param.paymentType = .CurrentBank
        // 充值的账号
        param.payAccountID = ""
        param.amount = Float(amount)
        let req: Promise<NullDataResponse> = handleRequest(Router.Endpoint(endpoint: EAccountPath.Recharge, param: param))
        req.then { (value) -> Void in
            // success
            }.error { (error) in
                if let err = error as? AppError {
                    Navigator.showAlertWithoutAction(nil, message: err.toError().localizedDescription)
                }
        }
    }
    
}

extension ImportExportViewController: ChooseCardProtocol {
    func dismissFromAddNewCard() {
        self.navigationController?.popToViewController(self, animated: true)
        dispatch_async(dispatch_get_main_queue()) {
            self.showChooseCard()
        }
    }
}

extension ImportExportViewController {
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 17.0
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if isImport {
            return 17.0
        } else {
            return 47.0
        }
    }
}

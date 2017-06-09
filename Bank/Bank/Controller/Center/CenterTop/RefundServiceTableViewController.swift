//
//  RefundServiceTableViewController.swift
//  Bank
//
//  Created by yang on 16/6/16.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import URLNavigator
import PromiseKit
import MBProgressHUD

class RefundServiceTableViewController: BaseTableViewController {
    
    @IBOutlet fileprivate var footerView: UIView!
    @IBOutlet fileprivate weak var moneyLabel: UILabel!
    @IBOutlet fileprivate weak var reasonLabel: UILabel!
    @IBOutlet fileprivate weak var charCountLabel: UILabel!
    @IBOutlet fileprivate weak var maskTextView: UITextView!
    @IBOutlet fileprivate weak var placeLabel: UILabel!

    var refundPrice: Float = 0
    var couponID: String?
    fileprivate var reasonArray: [ServiceRefundReason] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = footerView
        moneyLabel.text = "\(refundPrice.numberToString())元"
        maskTextView.delegate = self
        maskTextView.returnKeyType = .done
        if let reasons = AppConfig.shared.baseData?.serviceRefundReasons {
            reasonArray = reasons
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.segue.refundServiceTableViewController.showPickerView.identifier {
            guard let vc = segue.destination as? PickerViewController else { return }
            let array = self.reasonArray.map { return $0.reasonName }
            vc.dataSource = array
            vc.didSelect = { index in
                if index != -1 && self.reasonArray.count > index {
                    self.reasonLabel.text = array[index]
                }
            }
        }
    }

    //提交申请
    @IBAction func applyRefundAction(_ sender: UIButton) {
        if reasonLabel.text == R.string.localizable.alertTitle_please_choose_reason() {
            MBProgressHUD.errorMessage(view: self.view, message: R.string.localizable.alertTitle_please_choose_reason())
            return
        }
        requestSubmitRefundData()
    }

    func requestSubmitRefundData() {
        MBProgressHUD.loading(view: view)
        let param = OrderParameter()
        param.couponID = couponID
        param.reason = reasonLabel.text
        param.remark = maskTextView.text
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( OrderPath.order(.couponRefund), param: param))
        req.then { (value) -> Void in
            if value.isValid {
                self.setBackAlertViewController(nil, message: R.string.localizable.alertTitle_apply_success())
            }
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
    
    @IBAction func unwindRefundServiceFromPicker(_ segue: UIStoryboardSegue) {
        dim(.out, coverNavigationBar: true)
    }
    
    func showReasonPickerView() {
        dim(.in, coverNavigationBar: true)
        performSegue(withIdentifier: R.segue.refundServiceTableViewController.showPickerView, sender: nil)
    }
    
}

// MARK: UITableViewDataSource
extension RefundServiceTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return 2
    }

}

// MARK: UITableViewDelegate
extension RefundServiceTableViewController {
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 20
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 20
        }
        return 10
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            showReasonPickerView()
        }
    }

}

extension RefundServiceTableViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let count = textView.text.characters.count
        if textView.text.characters.isEmpty {
            placeLabel.text = "请补充退款说明(选填)"
        } else {
            placeLabel.text = ""
        }
        charCountLabel.text = "\(count)/100"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.characters.isEmpty {
            return true
        }
        if text == "\n" {
            view.endEditing(true)
        }
        if textView.text?.characters.count > 99 {
            return false
        }
        return true
    }
}

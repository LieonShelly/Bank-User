//
//  CheckOldMobileTableViewController.swift
//  Bank
//
//  Created by 杨锐 on 2017/2/13.
//  Copyright © 2017年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import URLNavigator
import PromiseKit
import MBProgressHUD
import Device

class CheckOldMobileTableViewController: BaseTableViewController {

    @IBOutlet var headerView: UIView!
    @IBOutlet var footerView: UIView!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var codeButton: CodeButton!
    @IBOutlet weak var progressImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.configBackgroundView()
        tableView.tableFooterView = footerView
        tableView.tableHeaderView = headerView
        mobileTextField.text = AppConfig.shared.keychainData.getMobile().toPhoneString()
        getCodeAction(codeButton)
        if Device.size() == .screen5_5Inch {
            progressImageView.contentMode = .scaleAspectFill
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    @IBAction func getCodeAction(_ sender: UIButton) {
        if mobileTextField.text?.characters.isEmpty == true {
            MBProgressHUD.errorMessage(view: view, message: "手机号为空")
        } else {
            self.codeButton.starTime()
            sendOldCode()
        }
    }
    
    /// 下一步
    @IBAction func nextAction(_ sender: UIButton) {
        if mobileTextField.text?.characters.isEmpty == true {
            MBProgressHUD.errorMessage(view: view, message: "手机号为空")
        } else if codeTextField.text?.characters.isEmpty == true {
            MBProgressHUD.errorMessage(view: view, message: "验证码为空")
        } else {
            verifyOldCode()
        }
    }
    
    /// 无法收到验证码
    @IBAction func receiveCodeFail(_ sender: UIButton) {
        guard let vc = R.storyboard.setting.chooseCheckTableViewController() else { return }
        Navigator.push(vc)
    }

}

// MARK: - Request
extension CheckOldMobileTableViewController {
    
    /// 发送原手机验证码
    func sendOldCode() {
        MBProgressHUD.loading(view: view)
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( UserPath.sendOldCode, param: nil))
        req.then { (value) -> Void in
            // success
            self.codeTextField.text = value.msg
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { error in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    /// 验证原手机号验证码
    func verifyOldCode() {
        let param = UserParameter()
        param.smsCode = codeTextField.text
        MBProgressHUD.loading(view: view)
        let req: Promise<GetUserInfoData> = handleRequest(Router.endpoint( UserPath.verifyOldCode, param: param))
        req.then { (value) -> Void in
            guard let vc = R.storyboard.setting.updateMobileTableViewController() else {
                return
            }
            vc.title = R.string.localizable.controller_title_update_mobile()
            vc.oldToken = value.data?.token
            Navigator.push(vc)
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { error in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
}

//
//  ContributePointViewController.swift
//  Bank
//
//  Created by yang on 16/4/29.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD

class ContributePointViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var headerView: UIView!
    @IBOutlet weak fileprivate var headImageView: UIImageView!
    @IBOutlet weak fileprivate var nameLabel: UILabel!
    @IBOutlet weak fileprivate var pointTextField: UITextField!
    
    fileprivate var noneBindUserView: NoneBindUserView!
    fileprivate var totalPoint: Int = 0
    // 0代表未绑定用户，1代表绑定用户
    var tag: Int!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.configBackgroundView()
        headerView.frame = tableView.bounds
        tableView.tableFooterView = headerView
        tabBarController?.tabBar.isHidden = true
        pointTextField.keyboardType = .numberPad
        pointTextField.delegate = self
        if tag == 0 {
            setNoneBindUserView()
        } else {
            requsetFatherInfo()
            requsetPoint()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     未绑定用户时的界面
     */
    func setNoneBindUserView() {
        noneBindUserView = R.nib.noneBindUserView.firstView(owner: nil)
        noneBindUserView.frame = view.bounds
        tableView.addSubview(noneBindUserView)
        noneBindUserView.applyUserHandleBlock = { [weak self] in
            self?.performSegue(withIdentifier: R.segue.contributePointViewController.showApplyUserVC, sender: nil)
        }
    }
    
    //贡献积分
    @IBAction func contributeAction(_ sender: UIButton) {
        MBProgressHUD.loading(view: view)
        vaildInput().then { (param) -> Promise<NullDataResponse> in
            let req: Promise<NullDataResponse> = handleRequest(Router.endpoint(UserPath.contributPoint, param: param))
            return req
            }.then { (value) -> Void in
                if value.isValid {
                    self.setBackAlertViewController(nil, message: R.string.localizable.alertTitle_contribution_score_success())
                }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                self.pointTextField.text = nil
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }

    }
    
    fileprivate func vaildInput() -> Promise<UserParameter> {
        return Promise { fufill, reject in
            let count = pointTextField.text?.characters.isEmpty == false
            switch count {
            case true:
                
                if let point = pointTextField.text, let inputPoint = Int(point) {
                    // 积分超限
                    if inputPoint > self.totalPoint {
                        let error = AppError(code: ValidInputsErrorCode.pointLimit)
                        reject(error)
                    } else {
                        let param = UserParameter()
                        param.point = Int(point)
                        fufill(param)
                    }
                } else {
                    let error = AppError(code: ValidInputsErrorCode.pointInvalidInput)
                    reject(error)
                }
                
            case false:
                let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                reject(error)
            }
        }
    }
    
    ///申请成为用户
    @IBAction func applyUserAction(_ sender: UIButton) {
        performSegue(withIdentifier: R.segue.contributePointViewController.showApplyUserVC, sender: nil)
    }
    
    ///请求用户的信息（非会员）
    func requsetFatherInfo() {
        let req: Promise<GetFatherUserInfoData> = handleRequest(Router.endpoint(UserPath.fatherInfo, param: nil))
        req.then { (value) -> Void in
            if value.isValid {
                if let father = value.data {
                    self.headImageView.setImage(with: father.imageURL, placeholderImage: R.image.head_default())
                    self.nameLabel.text = father.nickname
                }
            }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }

    }
    
    ///请求现有的积分
    func requsetPoint() {
        let req: Promise<GetPointData> = handleRequest(Router.endpoint( UserPath.totalPoint, param: nil))
        req.then { (value) -> Void in
            if value.isValid {
                if let point = value.data?.totalPoint {
                    if let point = Int(point) {
                        self.totalPoint = point
                    }
                    self.pointTextField.placeholder = "可贡献\(point)积分"
                }
            }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
        
    }
    
}

extension ContributePointViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let char = string.cString(using: .utf8)
        let isBackSpace = strcmp(char, "\\b")
        
        if isBackSpace == -92 {
            return true
        }
        return Util.isOnlyNumber(string)
    }
}

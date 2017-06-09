//
//  BindBulterViewController.swift
//  Bank
//
//  Created by yang on 16/3/25.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import ObjectMapper
import URLNavigator
import MBProgressHUD

class BindBulterViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var butlerTextField: UITextField!
    @IBOutlet fileprivate weak var remarkTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func helpHandle(_ sender: AnyObject) {
        guard let vc = R.storyboard.center.helpCenterHomeViewController() else {return}
        vc.tag = HelpCenterTag.butler
        Navigator.push(vc)
    }
    
    @IBAction func buttonHandle() {
        validInputs().then { param -> Promise<BaseResponseData> in
            let req: Promise<BaseResponseData> = handleRequest(Router.endpoint(endpoint: ButlerPath.bind, param: param))
            return req
            }.then { object -> Void in
                _ = self.navigationController?.popViewController(animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    fileprivate func validInputs() -> Promise<ButlerParameter> {
        return Promise { fulfill, reject in
            if let idText = butlerTextField.text, let remark = remarkTextField.text {
                let notEmpty = !idText.isEmpty && !remark.isEmpty
                if notEmpty {
                    let param = ButlerParameter()
                    param.butlerNo = butlerTextField.text
                    param.remark = remarkTextField.text
                    fulfill(param)
                } else {
                    let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                    reject(error)
                }
            } else {
                let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                reject(error)
            }
        }
    }
}

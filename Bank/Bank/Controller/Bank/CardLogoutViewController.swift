//
//  CardLogoutViewController.swift
//  Bank
//
//  Created by kilrae on 2017/4/18.
//  Copyright © 2017年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit

class CardLogoutViewController: BaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    
    fileprivate var payPassword: String?

    // MARK: - override function
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: contentView.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width, height: contentView.frame.height)
        scrollView.addSubview(contentView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - IBAction function
    
    @IBAction func logoutAction(_ sender: UIButton) {
        // 验证支付密码
        showVerifyPayPass()
    }
    
    // MARK: - fileprivate function
    
    /// 验证支付密码
    fileprivate func showVerifyPayPass() {
        guard let vc = R.storyboard.main.verifyPayPassViewController() else {
            return
        }
        vc.resultHandle = { [weak self] (result, pass) in
            self?.dim(.out, coverNavigationBar: true)
            vc.dismiss(animated: true, completion: nil)
            if result == .passed {
                self?.payPassword = pass
                self?.requestLogoutCard()
            }
        }
        dim(.in, coverNavigationBar: true)
        self.present(vc, animated: true, completion: nil)

    }
    
    /// 注销银行卡
    fileprivate func requestLogoutCard() {
        let parameter = BankCardParameter()
        parameter.payPass = payPassword
        
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( BankCardPath.logout, param: parameter))
        req.then { (value) -> Void in
            // 返回上一级页面
            self.performSegue(withIdentifier: R.segue.cardLogoutViewController.showCardListVC, sender: nil)
            }.catch { _ in }
    }

}

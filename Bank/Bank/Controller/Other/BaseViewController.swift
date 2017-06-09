//
//  BaseViewController.swift
//  Bank
//
//  Created by Koh Ryu on 11/17/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import MBProgressHUD
import PromiseKit
import URLNavigator

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    weak var containerController: ContainerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    // Tab Bar Controller Delegate
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let vc = viewController as? UINavigationController else { return }
        _ = vc.popToRootViewController(animated: false)
        tabBarController.selectedViewController = vc
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let index = tabBarController.viewControllers?.index(of: viewController) else { return false }
        if !AppConfig.shared.isLoginFlag && index == 3 {
            containerController?.needLogin()
            return false
        }
        return true
    }
    
}

class NavigationController: UINavigationController {
    
}

class BaseViewController: UIViewController {
    
    var helpHtmlName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackBarButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

extension UIViewController {
    
    func showSessionVC() {
        guard let _ = R.storyboard.session.instantiateInitialViewController(), let tabVC = self.tabBarController as? TabBarController else { return }
        tabVC.containerController?.needLogin()
    }
    
    func setBackBarButton() {
        let image = R.image.btn_left_arrow()?.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -5, bottom: -1.5, right: 5))
        navigationController?.navigationBar.backIndicatorImage = image
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = image
        let backBarItem = UIBarButtonItem(title: R.string.localizable.barButtonItem_title_back(), style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backBarItem
        view.backgroundColor = UIColor(hex: CustomKey.Color.viewBackgroundColor)
        navigationController?.navigationBar.hideBottomHairline()
        automaticallyAdjustsScrollViewInsets = false
    }
    
    func setBackBarButtonWithoutTitle() {
        let backBarItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backBarItem
    }
    
    /**
     设置返回的UI
     */
    func setLeftBarButton() {
        let image = R.image.btn_left_arrow()?.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -5, bottom: -1.5, right: 5))
        let button = UIButton(type: .custom)
        button.setTitle(R.string.localizable.button_title_back(), for: UIControlState())
        button.setImage(image, for: .normal)
        button.frame = CGRect(x: 0, y: 5, width: 100, height: 30)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        let barButtonItem = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = barButtonItem
        navigationItem.hidesBackButton = true
        button.addTarget(self, action: #selector(leftAction), for: .touchUpInside)
    }
    
    func setBlackLeftBarButton() {
        let image = R.image.btn_black_left()?.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -5, bottom: -1.5, right: 5))
        let button = UIButton(type: .custom)
        button.setTitle(R.string.localizable.button_title_back(), for: UIControlState())
        button.setImage(image, for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.frame = CGRect(x: 0, y: 5, width: 100, height: 30)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        let barButtonItem = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = barButtonItem
        navigationItem.hidesBackButton = true
        button.addTarget(self, action: #selector(leftAction), for: .touchUpInside)
    }
    
    func leftAction() {
        
    }

    func setTitleImageView(image: UIImage?) {
        let titleView: UIImageView = UIImageView(image: image)
        navigationItem.titleView = titleView
    }
    
    func setTitleView(view: UIView) {
        let titleView: UIView = view
        navigationItem.titleView = titleView
    }
    
    //拨打电话提示框
    func setTelAlertViewController(_ tel: String) {
        let alert = UIAlertController(title: nil, message: "\(tel)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "呼叫", style: .default, handler: { (action) in
            var string = "tel:"
            string.append(tel)
            if let url = URL(string: string) {
                UIApplication.shared.openURL(url)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // 点击弹框后返回上一级菜单
    func setBackAlertViewController(_ title: String? = "", message: String?, determinButton: String = R.string.localizable.alertTitle_okay()) {
        let theTitle = title
        let alert = UIAlertController(title: theTitle, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: determinButton, style: .default, handler: { [weak self] (action) in
            _ = self?.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)

    }
    
    // 找回密码弹框
    func setFundPassAlertController(_ title: String = "", message: String? = R.string.localizable.alertTitle_paypass_lock()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "找回密码", style: .default, handler: { [weak self] (action) in
            guard let vc = R.storyboard.setting.findPayPasswordCheckTableViewController() else { return }
            vc.isBackSetting = false
            self?.navigationController?.pushViewController(vc, animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    /// 去绑定银行卡弹框
    func showBindCardAlert() {
        let alert = UIAlertController(title: R.string.localizable.alertTitle_not_bind_card(), message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "去绑卡", style: .default, handler: { (action) in
            guard let vc = R.storyboard.bank.cardsListViewController() else {
                return
            }
            vc.lastViewController = self
            self.navigationController?.pushViewController(vc, animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

class BaseTableViewController: UITableViewController {
    
    var helpHtmlName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackBarButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

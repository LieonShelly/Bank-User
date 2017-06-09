//
//  MyTaskDetailViewController.swift
//  Bank
//
//  Created by yang on 16/5/23.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD

class MyEventDetailViewController: BaseViewController {

    @IBOutlet weak fileprivate var statusButton: UIButton!
    @IBOutlet weak fileprivate var childView: UIView!
    var joinID: String!
    var eventID: String!
    var isClosed: Bool = false
    var isApproved: Bool = false
    fileprivate var event: OfflineEvent?
    lazy var noneView: NoneView = {
       return NoneView(frame: self.view.bounds, type: .offlineEventDetail)
    }()
    
    // MARK: - override function
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isClosed || !isApproved {
            view.addSubview(noneView)
        } else {
            noneView.removeFromSuperview()
            requestTaskDetailData()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(qrcodeEventSuccess(_:)), name: .qrCodeEventSuccess, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? OfflineEventDetailViewController {
            vc.eventID = self.event?.eventID
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .qrCodeEventSuccess, object: nil)
    }

    // MARK: - fileprivate function
    
    fileprivate func setChildView() {
        for subview in childView.subviews {
            subview.removeFromSuperview()
        }
        for childVC in self.childViewControllers {
            childVC.removeFromParentViewController()
        }
        guard let vc = R.storyboard.point.myEventDetailTableViewController() else {
            return
        }
        vc.view.frame = childView.bounds
        childView.addSubview(vc.view)
        addChildViewController(vc)
        vc.event = self.event
    }
    
    @objc fileprivate func qrcodeEventSuccess(_ notification: Foundation.Notification) {
        self.requestTaskDetailData()
    }
    
    /**
     弹框
     */
    fileprivate func showAlert() {
        let alert = UIAlertController(title: R.string.localizable.alertTitle_is_cancel_sign(), message: nil, preferredStyle: .alert)
        let determinAction = UIAlertAction(title: R.string.localizable.alertTitle_confirm(), style: .default) { (action) in
            self.requestSign(self.eventID)
        }
        let cancelAction = UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: .cancel, handler: nil)
        alert.addAction(determinAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    /**
     请求活动详情
     */
    fileprivate func requestTaskDetailData() {
        MBProgressHUD.loading(view: view)
        let param = OfflineEventParameter()
        param.joinID = self.joinID
        let req: Promise<OfflineEventDetailData> = handleRequest(Router.endpoint(OfflineEventPath.signedDetail, param: param))
        req.then { (value) -> Void in
            if value.isValid {
                self.event = value.data
                self.setChildView()
                if let enable = self.event?.status?.enable {
                    self.statusButton.isEnabled = enable
                }
                if self.statusButton.isEnabled {
                    self.statusButton.backgroundColor = UIColor.orange
                } else {
                    self.statusButton.backgroundColor = UIColor.lightGray
                }
                self.statusButton.setTitle(self.event?.status?.title, for: .normal)
            }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
        
    }
    
    /**
     请求取消报名
    */
    fileprivate func requestSign(_ eventID: String) {
        MBProgressHUD.loading(view: view)
        let param = OfflineEventParameter()
        param.eventID = eventID
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( OfflineEventPath.signOut, param: param))
        req.then { (value) -> Void in
            _ = self.navigationController?.popViewController(animated: true)
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    // MARK: - IBAction function
    
    @IBAction func cancelAction(_ sender: UIButton) {
        showAlert()
    }

}

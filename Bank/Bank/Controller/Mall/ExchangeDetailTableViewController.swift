//
//  ExchangeDetailTableViewController.swift
//  Bank
//
//  Created by kilrae on 2017/4/27.
//  Copyright © 2017年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import MBProgressHUD

class ExchangeDetailTableViewController: BaseTableViewController {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
    
    var redeemID: String?
    
    fileprivate var point: PointObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        textView.delegate = self
        textView.linkTextAttributes = [NSForegroundColorAttributeName: UIColor(hex: 0x00a8fe)]
        requestData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    fileprivate func setTableView() {
        tableView.configBackgroundView()
        tableView.tableFooterView = UIView()
    }
    
    fileprivate func configUI() {
        guard let status = point?.approveStatus else { return }
        statusLabel.text = status.text
        if let point = point?.point, let money = self.point?.money {
            pointLabel.text = "\(point)积分(\(money)元)"
        }
        if let card = point?.card {
            accountLabel.text = "绵商银行卡(尾号\(card))"
        }
        if let name = point?.payee {
            nameLabel.text = "姓名(\(name))"
        }
        var flowCount: Int = 0
        switch status {
        case .fail, .success:
            flowCount = 3
        case .unApprove:
            flowCount = 2
        }
        
        for i in 0..<flowCount {
            guard let flowView = R.nib.refundFlowView.firstView(owner: nil) else {
                return
            }
            if let data = point {
                flowView.configInfo(point: data, row: i)
            }
            if i == flowCount - 1 {
                flowView.lineView.isHidden = true
            }
            stackView.addArrangedSubview(flowView)
        }
        stackViewHeight.constant = CGFloat(flowCount) * 85
        if let tel = AppConfig.shared.baseData?.serviceHotLine {
           textView.text = "如遇困难，您可拨打平台电话:\(tel)获取帮助，更多疑问请查看帮助中心"
        }
        tableView.reloadData()
    }
    
    fileprivate func requestData() {
        let hud = MBProgressHUD.loading(view: view)
        let param = MallParameter()
        param.redeemID = redeemID
        let req: Promise<PointRedeemInfoData> = handleRequest(Router.endpoint( MallPath.pointRedeemInfo, param: param))
        req.then { (value) -> Void in
            if let data = value.data {
                self.point = data
                self.configUI()
            }
            }.always {
                hud.hide(animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    @IBAction func closeAction(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return point == nil ? 0 : 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            return 50
        case (0, 1):
            return 100
        case (1, 0):
            return 40
        case (1, 1):
            return stackViewHeight.constant + 130
        default:
            return 44
        }
    }
}

// MARK: - UITextViewDelegate
extension ExchangeDetailTableViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        UIApplication.shared.openURL(URL)
        return false
    }
    
    @available(iOS 10, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.openURL(URL)
        return false
    }
}

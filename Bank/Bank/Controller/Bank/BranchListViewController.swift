//
//  BranchListViewController.swift
//  Bank
//
//  Created by Koh Ryu on 16/6/15.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD

class BranchListViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var textField: UITextField!
    @IBOutlet fileprivate weak var searchButton: UIButton!
    
    fileprivate var datas: [Branch] = []
    fileprivate lazy var noneView: NoneView = { return NoneView(frame: self.tableView.bounds, type: .other)}()
    
    fileprivate var keyword: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 120.0
        tableView.register(R.nib.bankBranchTableViewCell)
        tableView.tableFooterView = UIView()
        tableView.configBackgroundView()
        NotificationCenter.default.addObserver(self, selector: #selector(self.textChanged(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        searchButton.isEnabled = false
        textField.returnKeyType = .search
        requestDatas()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    fileprivate func requestDatas(_ page: Int = 1, keyword: String? = nil) {
        MBProgressHUD.loading(view: view)
        let param = AppointParameter()
        param.page = page
        param.keyword = keyword
        let req: Promise<BranchListData> = handleRequest(Router.endpoint(endpoint: AppointPath.bankBranch, param: param))
        req.then { (value) -> Void in
            if let items = value.data?.items {
                self.datas = items
            }
            self.keyword = keyword
            self.tableView.reloadData()
            if self.datas.isEmpty {
                self.tableView.tableFooterView = self.noneView
            } else {
                self.tableView.tableFooterView = UIView()
            }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    @IBAction fileprivate func searchHandle() {
        textField.resignFirstResponder()
        requestDatas(keyword: textField.text)
    }
    
    @objc fileprivate func textChanged(_ notification: Foundation.Notification) {
        if let textField = notification.object as? UITextField {
            if let searchKeyword = textField.text, !searchKeyword.isEmpty {
                searchButton.isEnabled = true
                return
            }
        }
        searchButton.isEnabled = false
    }
    
}

extension BranchListViewController: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        requestDatas()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty {
            searchHandle()
            return true
        }
        return false
    }
}

extension BranchListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.bankBranchTableViewCell, for: indexPath) else {
            return UITableViewCell()
        }
        cell.configData(datas[indexPath.row], keyword: keyword)
        cell.controller = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
}

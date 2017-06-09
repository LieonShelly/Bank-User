//
//  ChooseBranchViewController.swift
//  Bank
//
//  Created by Koh Ryu on 16/4/6.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import Eureka
import PromiseKit
import URLNavigator
import MBProgressHUD

class ChooseBranchViewController: BaseTableViewController, TypedRowControllerType {

    var row: RowOf<Branch>!
    var onDismissCallback: ((UIViewController) -> Void)?
    
    fileprivate var searchBar: UISearchBar = UISearchBar()
    
    fileprivate var datas: [Branch] = []
    fileprivate var keyword: String?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience public init(_ callback: ((UIViewController) -> Void)?) {
        self.init(nibName: nil, bundle: nil)
        onDismissCallback = callback
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.rowHeight = 88.0
        tableView.register(R.nib.chooseBranchTableViewCell)
        let leftItem = UIBarButtonItem(image: R.image.btn_left_arrow(), style: .plain, target: self, action: #selector(self.popSelf))
        navigationItem.leftBarButtonItem = leftItem
        
        let rightItem = UIBarButtonItem(title: R.string.localizable.barButtonItem_title_search(), style: .plain, target: self, action: #selector(self.searchHandle))
        rightItem.isEnabled = false
        navigationItem.rightBarButtonItem = rightItem
        
        navigationItem.titleView = searchBar
        requestData()
    }

    func requestData(_ page: Int = 1, keyword: String? = nil) {
        let param = AppointParameter()
        param.page = page
        param.keyword = keyword
        MBProgressHUD.loading(view: view)
        let req: Promise<BranchListData> = handleRequest(Router.endpoint(endpoint: AppointPath.bankBranch, param: param))
        req.then { value -> Void in
            if let items = value.data?.items {
                self.datas = items
                self.tableView.reloadData()
            }
            self.keyword = keyword
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    @objc fileprivate func searchHandle() {
        searchBar.resignFirstResponder()
        requestData(keyword: searchBar.text)
    }
    
    @objc fileprivate func popSelf() {
        _ = navigationController?.popViewController(animated: true)
    }
    
}

extension ChooseBranchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            DispatchQueue.main.async(execute: { 
                self.searchBar.resignFirstResponder()
            })
            requestData()
        }
        navigationItem.rightBarButtonItem?.isEnabled = !searchText.isEmpty
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        requestData(keyword: searchBar.text)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}

extension ChooseBranchViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.chooseBranchTableViewCell) else {
            return UITableViewCell()
        }
        cell.configBranch(datas[indexPath.row], keyword: keyword)
        return cell
    }
}

extension ChooseBranchViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let branch = datas[indexPath.row]
        row.value = branch
        onDismissCallback?(self)
    }
}

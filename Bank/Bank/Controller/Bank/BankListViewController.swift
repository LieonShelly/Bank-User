//
//  BankListTableViewController.swift
//  Bank
//
//  Created by Koh Ryu on 16/7/14.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class BankListViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    fileprivate var banks: [Bank] = []
    
    var dismiss: ((Bank?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = R.string.localizable.controller_title_transfer_other()
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        tableView.delegate = self
        tableView.rowHeight = 50
        requestData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func requestData() {
        guard var list = AppConfig.sharedManager.baseData?.bankList else { return }
        list.removeFirst()
         banks = list
        tableView.reloadData()
    }

}

extension BankListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return banks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellID")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cellID")
        }
        cell?.accessoryType = .disclosureIndicator
        if indexPath.row < banks.count {
            cell?.textLabel?.text = banks[indexPath.row].name
            if let name = banks[indexPath.row].name {
                cell?.imageView?.image = UIImage(named: "\(String().translateChineseIntoPinyin(name, isAbbreviation: true)).png")
            }
        }
        return cell ?? UITableViewCell()
    }
}

extension BankListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
            if let block = dismiss {
                block(banks[indexPath.row])
            }
            _ = self.navigationController?.popViewController(animated: true)
    }
}

//
//  BrandDetailMoreViewController.swift
//  Bank
//
//  Created by yang on 16/4/5.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import URLNavigator
import PromiseKit
class BrandDetailMoreViewController: BaseViewController {

    @IBOutlet fileprivate weak var searchTextField: UITextField!
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate var headerView: UIView!
    
    fileprivate var selectedCatID: String!
    var dataArray: [Classify] = []
    var selectedMerchant: Merchant?
    var selectedHandleBlock: ((_ storeCatID: String?) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        searchTextField.delegate = self
        setTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.3, animations: { 
            self.view.frame = UIScreen.main.bounds
            }, completion: { (isFinished) in
                
        }) 
    }
    
    fileprivate func setTableView() {
        tableView.backgroundColor = UIColor(hex: CustomKey.Color.viewBackgroundColor)
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = headerView
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.register(R.nib.brandDetailMoreTableViewCell)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func backAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: { 
            self.view.frame = CGRect(x: -self.view.frame.width, y: self.view.frame.origin.y, width: self.view.frame.width, height: self.view.frame.height)
            
            }, completion: { (isFisined) in
                self.removeFromParentViewController()
                self.view.removeFromSuperview()
        }) 
    }
}

// MARK: UITableViewDataSource
extension BrandDetailMoreViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.brandDetailMoreTableViewCell, for: indexPath) else {
            return UITableViewCell()
        }
        cell.catLabel.text = dataArray[indexPath.row].name
        return cell
    }
}

// MARK: UITableViewDelegate
extension BrandDetailMoreViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCatID = dataArray[indexPath.row].classifyID
        if let block = selectedHandleBlock {
            block(selectedCatID)
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

// MARK: - UITextFieldDelegate
extension BrandDetailMoreViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let block = selectedHandleBlock {
            block(nil)
        }
        return false
    }

}

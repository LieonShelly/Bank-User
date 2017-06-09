//
//  AddressManagementTableViewController.swift
//  Bank
//
//  Created by Mac on 15/11/27.
//  Copyright © 2015年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import ObjectMapper
import MBProgressHUD

class AddressManagementTableViewController: BaseTableViewController {
    enum AddressType {
        case selected
        case edit
    }
    @IBOutlet fileprivate var footView: UIView!
    var lastViewController: BaseViewController?
    var selectedAddress: Address?
    fileprivate lazy var noneView: NoneView = { return NoneView(frame: self.tableView.bounds, type: .address)}()
    fileprivate var provinceRegions: [ProvinceRegions] = []
    fileprivate var addressArray: [Address] = []
    var addressType: AddressType = .edit
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        requestRegionData()
        setTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EditAddressTableViewController {
            vc.address = selectedAddress
            vc.provinceRegions = self.provinceRegions
        }
        
        if let vc = segue.destination as? AddNewAddressTableViewController {
            vc.provinceRegions = self.provinceRegions
        }
    }
    
    func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(R.nib.addressManagementTableViewCell)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.configBackgroundView()
    }
    
    func requestData() {
        MBProgressHUD.loading(view: view)
        let req: Promise<AddressListData> = handleRequest(Router.endpoint( OrderPath.address(.list), param: nil))
        req.then { (value) -> Void in
            if value.isValid {
                if let array = value.data?.addressList {
                    self.addressArray = array
                    if array.isEmpty {
                        self.tableView.tableFooterView = self.noneView
                        self.noneView.buttonHandleBlock = { [weak self] in
                            self?.addNewAddressAction()
                        }
                    } else {
                        self.tableView.tableFooterView = self.footView
                    }
                    self.tableView.reloadData()
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
    
    /// 请求省市区的region
    func requestRegionData() {
        let dateString = Date().toString("yyyy-MM-dd")
        let lastLoginDateString = UserDefaults.standard.string(forKey: CustomKey.UserDefaultsKey.loginDate)

        if lastLoginDateString != dateString {
            MBProgressHUD.loading(view: view)
            let req: Promise<RegionCodeListData> = handleRequest(Router.endpoint( HomeBasicPath.regionCode, param: nil), needToken: .default)
            req.then(on: DispatchQueue.global()) { (value) -> Void in
                if let data = value.data {
                    data.saveToCache(key: CustomKey.CacheKey.regionKey)
                    UserDefaults.standard.set(dateString, forKey: CustomKey.UserDefaultsKey.loginDate)
                }
                if let regions = value.data?.regions {
                    self.provinceRegions = regions
                }
                }.always {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }.catch { (error) in
                    RegionCodeList.getFromCache(key: CustomKey.CacheKey.regionKey, block: { (data) in
                        if let regions = data.regions {
                            self.provinceRegions = regions
                        }
                    })
            }
        } else {
            RegionCodeList.getFromCache(key: CustomKey.CacheKey.regionKey, block: { (data) in
                if let regions = data.regions {
                    self.provinceRegions = regions
                }
            })
        }
    }

    @IBAction func addNewAddressAction() {
        self.performSegue(withIdentifier: R.segue.addressManagementTableViewController.showAddNewAddressVC, sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return addressArray.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: AddressManagementTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.addressManagementTableViewCell, for: indexPath) else {return UITableViewCell()}
        cell.configInfo(addressArray[indexPath.section])
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 15
        }
        return 8
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedAddress = addressArray[indexPath.section]
        if addressType == .edit {
            self.performSegue(withIdentifier: R.segue.addressManagementTableViewController.showEditAddressVC, sender: nil)
        } else {
            guard let lastVC = lastViewController as? SubmitOrderViewController else {
                return
            }
            lastVC.selectedAddress = selectedAddress
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
}

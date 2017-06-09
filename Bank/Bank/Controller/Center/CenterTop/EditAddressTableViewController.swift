//
//  EditAddressTableViewController.swift
//  Bank
//
//  Created by yang on 16/4/20.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import URLNavigator
import PromiseKit
import MBProgressHUD

class EditAddressTableViewController: BaseTableViewController {

    @IBOutlet fileprivate var editToolView: UIView!
    @IBOutlet fileprivate weak var nameTextField: UITextField!
    @IBOutlet fileprivate weak var phoneTextField: UITextField!
    @IBOutlet fileprivate weak var postCodeTextField: UITextField!
    @IBOutlet fileprivate weak var regionTextField: UITextField!
    @IBOutlet fileprivate weak var detailAddressTextField: UITextField!
    @IBOutlet fileprivate weak var defaultAddressButton: UIButton!
    
    fileprivate var regionView: RegionChoiceToolView!
    fileprivate var selectedProvince: ProvinceRegions?
    fileprivate var selectedCity: CityRegions?
    fileprivate var selectedDistrict: DistrictRegions?
    fileprivate var regionPath: String?
    fileprivate var blackView: UIView!
    
    var provinceRegions: [ProvinceRegions] = []
    var address: Address?

    override func viewDidLoad() {
        super.viewDidLoad()
        editToolView.frame = CGRect(x: 0, y: tableView.frame.height, width: view.frame.width, height: 50)
        view.addSubview(editToolView)
        tableView.configBackgroundView()
        tableView.tableFooterView = UIView()
        defaultAddressButton.setImage(R.image.btn_choice_yes(), for: .selected)
        defaultAddressButton.setImage(R.image.btn_choice_no(), for: .normal)
        defaultAddressButton.titleLabel?.adjustsFontSizeToFitWidth = true
        setAddress()
        setPickerView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5, animations: { 
            self.editToolView.frame = CGRect(x: 0, y: self.view.frame.height - 50, width: self.view.frame.width, height: 50)
        }) 
    }
    
    fileprivate func setAddress() {
        nameTextField.text = address?.name
        phoneTextField.text = address?.mobile
        postCodeTextField.text = address?.postCode
        regionTextField.text = address?.region
        regionPath = address?.regionPath
        detailAddressTextField.text = address?.address
        if let isDefault = address?.isDefault {
            defaultAddressButton.isSelected = isDefault
        }
    }

    @IBAction func defalutAddressAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    /**
     修改地址
    */
    @IBAction func saveAction(_ sender: UIButton) {
        vaildInput().then { (param) -> Promise<NullDataResponse> in
            let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( OrderPath.address(.edit), param: param))
            return req
            }.then { (value) -> Void in
                if value.isValid {
                    Navigator.showAlertWithoutAction(nil, message: R.string.localizable.alertTitle_revise_success())
                }
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }

    }
    
    fileprivate func vaildInput() -> Promise<AddressParameter> {
        return Promise { fulfill, reject in
            guard let name = nameTextField.text else {
                let error = AppError(code: ValidInputsErrorCode.nameEmpty, msg: nil)
                return reject(error)
            }
            guard let phone = phoneTextField.text else {
                let error = AppError(code: ValidInputsErrorCode.phoneEmpty, msg: nil)
                return reject(error)
            }
            guard let region = regionTextField.text else {
                let error = AppError(code: ValidInputsErrorCode.addressEmpty, msg: nil)
                return reject(error)
            }
            guard let detail = detailAddressTextField.text else {
                let error = AppError(code: ValidInputsErrorCode.addressEmpty, msg: nil)
                return reject(error)
            }
            if name.characters.isEmpty {
                let error = AppError(code: ValidInputsErrorCode.nameEmpty, msg: nil)
                reject(error)
            } else if phone.characters.isEmpty {
                let error = AppError(code: ValidInputsErrorCode.phoneEmpty, msg: nil)
                reject(error)
            } else if region.characters.isEmpty || detail.characters.isEmpty {
                let error = AppError(code: ValidInputsErrorCode.addressEmpty, msg: nil)
                reject(error)
            } else if vaildInput(text: name, count: 10, isNeedRegx: true) == false {
                // 请输入正确的姓名
                let error = AppError(code: ValidInputsErrorCode.nameError, msg: nil)
                reject(error)
            } else if vaildInput(text: phone, count: 11, isNeedRegx: false) == false {
                // 请输入正确的手机号
                let error = AppError(code: ValidInputsErrorCode.inputRightPhoneNumber, msg: nil)
                reject(error)
                
            } else if vaildInput(text: postCodeTextField.text, count: 6, isNeedRegx: false, isRequired: false) == false {
                // 请输入正确的邮编
                let error = AppError(code: ValidInputsErrorCode.postCodeError, msg: nil)
                reject(error)
            } else {
                let param = AddressParameter()
                param.addressID = address?.addressID
                param.name = nameTextField.text
                param.mobile = phoneTextField.text
                param.postCode = postCodeTextField.text
                param.region = regionTextField.text
                if let provinceCode = selectedProvince?.code, let cityCode = selectedCity?.code, let districtCode = selectedDistrict?.code {
                    self.regionPath = provinceCode + "," + cityCode + "," + districtCode
                }
                param.regionPath = self.regionPath
                param.address = detailAddressTextField.text
                param.isDefault = defaultAddressButton.isSelected
                return fulfill(param)
            }
        }
    }
    /**
     删除地址
          */
    @IBAction func deleteAction(_ sender: UIButton) {
        showAlertController(R.string.localizable.alertTitle_is_delete_address())
    }
    
    fileprivate func showAlertController(_ message: String) {
        let alert = UIAlertController(title: R.string.localizable.alertTitle_tip(), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_confirm(), style: .default, handler: { [weak self] (action) in
            self?.requestDeleteAddress()
        }))
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func vaildInput(text: String?, count: Int, isNeedRegx: Bool, isRequired: Bool = true) -> Bool {
        var isChinese: Bool = true
        if isNeedRegx {
            let regx = "^[\\u4e00-\\u9fa5]+$"
            let pre = NSPredicate(format: "SELF MATCHES %@", regx)
            isChinese = pre.evaluate(with: text)
        }
        guard let num = text?.characters.count else {
            if isRequired == false {
                return true
            }
            return false
        }
        if num <= count && isChinese == true {
            return true
        } else {
            return false
        }
    }

    /**
     删除地址
     */
    fileprivate func requestDeleteAddress() {
        MBProgressHUD.loading(view: view)
        let param = OrderParameter()
        param.addressID = address?.addressID
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( OrderPath.address(.delete), param: param))
        req.then { (value) -> Void in
            if value.isValid {
                _ = self.navigationController?.popViewController(animated: true)
            }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }

    }
    
    // MARK: - SetPickerView
    fileprivate func setPickerView() {
        if regionView == nil {
            blackView = UIView(frame: UIScreen.main.bounds)
            blackView.backgroundColor = UIColor.black
            blackView.alpha = 0
            let tap = UITapGestureRecognizer(target: self, action: #selector(close))
            blackView.addGestureRecognizer(tap)
            navigationController?.view.addSubview(blackView)
            regionView = R.nib.regionChoiceToolView.firstView(owner: nil)
            navigationController?.view.addSubview(regionView)
        }
        regionView?.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: view.frame.width, height: 220)

        regionView.finishHandleBlock = { (province, city, district) in
            self.selectedProvince = province
            self.selectedCity = city
            self.selectedDistrict = district
            if let provinceName = province.name, let cityName = city.name, let districtName = district.name {
                self.regionTextField.text = provinceName + cityName + districtName
            }
            self.close()
        }
        
        regionView.cancelHandleBlock = {
            self.close()
        }
        if let cityArray = provinceRegions[0].cityRegions {
            if let districtArray = cityArray[0].districtRegions {
                regionView.setPickerData(provinceRegions, city: cityArray, district: districtArray)
            }
        }
    }
    
    fileprivate func open() {
        blackView.alpha = 0.5
        UIView.animate(withDuration: 0.5, animations: {
            self.regionView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 220, width: self.view.frame.width, height: 220)
        }) 
    }
    
    @objc fileprivate func close() {
        blackView.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.regionView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: self.view.frame.width, height: 220)
        }) 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 3 {
            if regionView == nil {
                return
            }
            view.endEditing(true)
            open()
            
        }
    }
    
    override func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }

}

// MARK: - UITextFieldDelegate
extension EditAddressTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 2 {
            return validatePhoneNumberWithoutSpace(textField, shouldChangeCharactersInRange: range, replacementString: string)
        }
        return true
    }

}

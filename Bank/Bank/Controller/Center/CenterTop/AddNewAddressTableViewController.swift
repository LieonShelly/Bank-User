//
//  AddNewAddressTableViewController.swift
//  Bank
//
//  Created by yang on 16/4/20.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD

class AddNewAddressTableViewController: BaseTableViewController {

    @IBOutlet fileprivate var footView: UIView!
    @IBOutlet fileprivate weak var nameTextField: UITextField!
    @IBOutlet fileprivate weak var phoneTextField: UITextField!
    @IBOutlet fileprivate weak var postCodeTextField: UITextField!
    @IBOutlet fileprivate weak var regionTextField: UITextField!
    @IBOutlet fileprivate weak var detailAddressTextField: UITextField!
    
    fileprivate var regionView: RegionChoiceToolView!
    fileprivate var selectedProvince: ProvinceRegions?
    fileprivate var selectedCity: CityRegions?
    fileprivate var selectedDistrict: DistrictRegions?
    fileprivate var blackView: UIView!
    var provinceRegions: [ProvinceRegions] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.configBackgroundView()
        tableView.tableFooterView = footView
        self.setPickerView()
        tableView.keyboardDismissMode = .interactive
    }
    
    /**
     添加地址
     */
    @IBAction func saveAction(_ sender: UIButton) {
        MBProgressHUD.loading(view: view)
        vaildInput().then { (param) -> Promise<AddNewAddressData> in
            let req: Promise<AddNewAddressData> = handleRequest(Router.endpoint( OrderPath.address(.add), param: param))
            return req
        }.then { (value) -> Void in
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
    
    fileprivate func vaildInput() -> Promise<AddressParameter> {
        return Promise { fulfill, reject in
            guard let name = nameTextField.text else {
                let error = AppError(code: ValidInputsErrorCode.nameEmpty, msg: nil)
               return reject(error)
            }
            guard let phone = phoneTextField.text?.stringByRemovingCharactersInSet(CharacterSet.whitespaces) else {
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
                param.name = nameTextField.text
                param.mobile = phoneTextField.text?.stringByRemovingCharactersInSet(CharacterSet.whitespaces)
                param.postCode = postCodeTextField.text
                param.region = regionTextField.text
                if let provinceCode = selectedProvince?.code, let cityCode = selectedCity?.code, let districtCode = selectedDistrict?.code {
                    param.regionPath = provinceCode + "," + cityCode + "," + districtCode
                }
                param.address = detailAddressTextField.text
                return fulfill(param)
            }
        }
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
        for (proIndex, provinceRegion) in zip(provinceRegions.indices, provinceRegions) where provinceRegion.name == "四川" {
            self.selectedProvince = provinceRegion
            guard let citys = provinceRegion.cityRegions else { continue }
            for (cityIndex, city) in zip(citys.indices, citys) where city.name == "绵阳" {
                self.selectedCity = city
                guard let districts = city.districtRegions else { continue }
                for (disIndex, district) in zip(districts.indices, districts) where district.name == "涪城区" {
                    self.selectedDistrict = district
                    regionView.provinceIndex = proIndex
                    regionView.cityIndex = cityIndex
                    regionView.districyIndex = disIndex
                    regionView.setPickerData(provinceRegions, city: citys, district: districts)
                    regionTextField.text = "四川绵阳涪城区"
                }
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
    }
}

extension AddNewAddressTableViewController {
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 3 {
            if regionView == nil {
                return
            }
            view.endEditing(true)
            open()
            
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 17.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 17.0
    }
    
    override func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate
extension AddNewAddressTableViewController: UITextFieldDelegate {
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

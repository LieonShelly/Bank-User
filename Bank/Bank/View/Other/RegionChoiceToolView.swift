//
//  RegionChoiceToolView.swift
//  Bank
//
//  Created by yang on 16/4/20.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
class RegionChoiceToolView: UIView {
    
    @IBOutlet fileprivate weak var regionPickerView: UIPickerView!
    var finishHandleBlock: ((_ province: ProvinceRegions, _ city: CityRegions, _ district: DistrictRegions) -> Void)?
    var cancelHandleBlock: (() -> Void)?
    var provinceArray: [ProvinceRegions] = []
    var cityArray: [CityRegions] = []
    var districtArray: [DistrictRegions] = []
    var provinceIndex: Int = 0
    var cityIndex: Int = 0
    var districyIndex: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func setPickerData(_ province: [ProvinceRegions], city: [CityRegions], district: [DistrictRegions]) {
        provinceArray = province
        cityArray = city
        districtArray = district
        regionPickerView.dataSource = self
        regionPickerView.delegate = self
        regionPickerView.showsSelectionIndicator = true
        regionPickerView.selectRow(provinceIndex, inComponent: 0, animated: true)
        regionPickerView.selectRow(cityIndex, inComponent: 1, animated: true)
        regionPickerView.selectRow(districyIndex, inComponent: 2, animated: true)
    }
    
    @IBAction func finishAction(_ sender: UIButton) {
        if let block = finishHandleBlock {
            block(provinceArray[provinceIndex], cityArray[cityIndex], districtArray[districyIndex])
        }
    }

    @IBAction func cancelAction(_ sender: UIButton) {
        if let block = cancelHandleBlock {
            block()
        }
    }
}

extension RegionChoiceToolView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return provinceArray.count
        } else if component == 1 {
            return cityArray.count
        } else {
            return districtArray.count
        }
    }
}

extension RegionChoiceToolView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return (screenWidth-15)/3.0
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 45
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label: UILabel!
        if view == nil {
            label = UILabel()
            label.textColor = UIColor(hex: 0x1c1c1c)
            label.adjustsFontSizeToFitWidth = true
            label.textAlignment = .center
            label.numberOfLines = 2
        } else {
            guard let view = view as? UILabel else {
                return UILabel()
            }
            label = view
        }
        if component == 0 {
            label?.text = provinceArray[row].name
        } else if component == 1 {
            label?.text = cityArray[row].name
        } else {
            label?.text = districtArray[row].name
        }
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            if let array1 = provinceArray[row].cityRegions {
                cityArray = array1
                pickerView.reloadComponent(1)
                if let array2 = cityArray[0].districtRegions {
                    districtArray = array2
                    pickerView.reloadComponent(2)
                    pickerView.selectRow(0, inComponent: 1, animated: true)
                    pickerView.selectRow(0, inComponent: 2, animated: true)
                    provinceIndex = row
                    cityIndex = 0
                    districyIndex = 0
                }
            }
            
        } else if component == 1 {
            if let array = cityArray[row].districtRegions {
                districtArray = array
                pickerView.reloadComponent(2)
                pickerView.selectRow(0, inComponent: 2, animated: true)
                cityIndex = row
                districyIndex = 0
            }
        } else {
            districyIndex = row
        }
    }
}

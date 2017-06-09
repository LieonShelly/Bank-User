//
//  PickerViewController.swift
//  Bank
//
//  Created by Koh Ryu on 16/5/11.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class PickerViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var pickerView: UIPickerView!
    @IBOutlet fileprivate weak var datePicker: UIDatePicker!
    
    var dataSource: [String?] = []
    var didSelect: ((_ index: Int) -> Void)?
    var didSelectDate: ((_ date: Date) -> Void)?
    var dismiss: (() -> Void)?
    
    var dateMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        
        if dateMode {
            pickerView.isHidden = true
            datePicker.datePickerMode = .date
            datePicker.maximumDate = Date()
        } else {
            datePicker.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction fileprivate func dismissHandle() {
        if let block = dismiss {
            block()
        }
        if dateMode {
            performSegue(withIdentifier: R.segue.pickerViewController.unwindScreenFromPicker, sender: nil)
        } else {
            performSegue(withIdentifier: R.segue.pickerViewController.unwindFeedbackFromPicker, sender: nil)
            performSegue(withIdentifier: R.segue.pickerViewController.unwindRefundGoodsFromPicker, sender: nil)
            performSegue(withIdentifier: R.segue.pickerViewController.unwindRefundServiceFromPicker, sender: nil)
            performSegue(withIdentifier: R.segue.pickerViewController.unwindApplyUserFromPicker, sender: nil)
        }
    }
    
    @IBAction fileprivate func confirmHandle() {
        if let block = didSelect {
            block(pickerView.selectedRow(inComponent: 0))
        }
        if let block = didSelectDate {
            block(datePicker.date)
        }
        dismissHandle()
    }

}

extension PickerViewController: UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}

extension PickerViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSource[row]
    }
}

//
//  WaterFeeViewController.swift
//  Bank
//
//  Created by Koh Ryu on 11/23/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class FeeQueryViewController: BaseTableViewController {

    @IBOutlet private weak var companyDescLabel: UILabel!
    @IBOutlet private weak var numDescLabel: UILabel!
    @IBOutlet private weak var iconButton: UIButton!
    @IBOutlet private weak var companyTextField: UITextField!
    @IBOutlet private weak var numTextField: UITextField!
    @IBOutlet private weak var tipLabel: UILabel!
    
    @IBOutlet private weak var pickerView: UIPickerView!
    private var toolBar: InputAccessoryToolbar!
    
    var serviceType: LifeServiceType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if serviceType != .Ticket && serviceType != .Tel {
            toolBar = R.nib.inputAccessoryToolbar.firstView(owner: self, options: nil)
            toolBar.doneHandleBlock = {
                self.view.endEditing(true)
            }
            toolBar.cancelHandleBlock = {
                self.view.endEditing(true)
            }
            companyTextField.inputView = pickerView
            companyTextField.inputAccessoryView = toolBar
            numTextField.inputAccessoryView = toolBar
        }
        title = serviceType.title
        tipLabel.text = serviceType.tipString
        companyDescLabel.text = serviceType.companyDesc
        if let data = serviceType.companyData {
            if serviceType != .Ticket {
                companyTextField.text = data[0]
            }
        }
        
        numDescLabel.text = serviceType.numberDesc
        numTextField.placeholder = serviceType.placeholder
        iconButton.setImage(serviceType.iconName, forState: .Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == R.segue.feeQueryViewController.showQueryNextVC.identifier {
            if let vc = segue.destinationViewController as? FeeViewController {
                vc.serviceType = serviceType
                if serviceType == .Ticket {
                    vc.queryString = companyTextField.text
                } else {
                    vc.queryString = numTextField.text
                }
                vc.company = companyTextField.text
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == R.segue.feeQueryViewController.showQueryNextVC.identifier {
            if numTextField.text?.characters.isEmpty == true {
                let alertVC = UIAlertController(title: "", message: "请填写内容", preferredStyle: UIAlertControllerStyle.Alert)
                alertVC.addAction(UIAlertAction(title: "好的", style: UIAlertActionStyle.Cancel, handler: nil))
                presentViewController(alertVC, animated: true, completion: nil)
                return false
            }
        }
        return true
    }
    
    // MARK: Method
    
    @IBAction func viewTapHandle() {
        view.endEditing(true)
    }

}

// Table View Delegate
extension FeeQueryViewController {
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Const.TableView.SectionHeight.Header17
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return Const.TableView.SectionHeight.Header17
    }
}

// MARK: Picker View Data Source
extension FeeQueryViewController: UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return serviceType.companyData?.count ?? 1
    }
}

// MARK: Picker View Delegate
extension FeeQueryViewController: UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return serviceType.companyData?[row]
    }
}

//
//  ChangeGoodsNumberView.swift
//  Bank
//
//  Created by yang on 16/7/7.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import MBProgressHUD

class ChangeGoodsNumberView: UIView {
    @IBOutlet fileprivate weak var backView: UIView!
    @IBOutlet fileprivate weak var numberTextField: UITextField!
    @IBOutlet fileprivate weak var reduceButton: UIButton!
    var determinHandleBlock: ((_ number: Int) -> Void)?
    var cancelHandleBlock: (() -> Void)?
    var number: Int = 1 {
        didSet {
            numberTextField.text = String(number)
            if number == 1 {
                reduceButton.setTitleColor(UIColor(hex: 0xb2b2b2), for: UIControlState())
            } else {
                reduceButton.setTitleColor(UIColor(hex: 0x333333), for: UIControlState())
            }
        }
    }
    var stockNumber: Int = 99 {
        didSet {
            stockNumber = stockNumber > 99 ? 99 : stockNumber
        }
    }
    
    override func awakeFromNib() {
        numberTextField.delegate = self
        numberTextField.keyboardType = .numberPad
        numberTextField.returnKeyType = .done
        numberTextField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
    }
    
    func textChanged(_ textField: UITextField) {
        if let text = textField.text, let num = Int(text) {
            if num > stockNumber {
                MBProgressHUD.errorMessage(view: self, message: "购买数量最多为\(stockNumber)")
                textField.text = "\(stockNumber)"
            }
        }
    }

    @IBAction func reduceAction(_ sender: UIButton) {
        if let text = numberTextField.text, let num = Int(text) {
            number = num
        }
        if number > 1 {
            number -= 1
            reduceButton.setTitleColor(UIColor(hex: 0x333333), for: UIControlState())
        } else {
            reduceButton.setTitleColor(UIColor(hex: 0xb2b2b2), for: UIControlState())
        }
    }
    @IBAction func addAction(_ sender: UIButton) {
        if let text = numberTextField.text, let num = Int(text) {
            number = num
        }
        if number >= stockNumber {
            MBProgressHUD.errorMessage(view: self, message: "购买数量最多为\(stockNumber)")
            return
        }
        number += 1
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.endEditing(true)
        if let block = cancelHandleBlock {
            block()
        }
    }
    
    @IBAction func determinAction(_ sender: UIButton) {
        self.endEditing(true)
        if numberTextField.text == nil {
            return
        }
        if let block = determinHandleBlock {
            block(number)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
}

extension ChangeGoodsNumberView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "" {
            return true
        }
        if textField.text == "0" {
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else {return}
        if text.characters.isEmpty {
            return
        }
        if let text = textField.text, let num = Int(text) {
            number = num
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, let num = Int(text) {
            number = num
        }
        textField.endEditing(true)
        return true
    }
}

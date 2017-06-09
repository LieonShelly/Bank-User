//
//  PhoneChargeViewController.swift
//  Bank
//
//  Created by Koh Ryu on 11/20/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//
// swiftlint:disable force_unwrapping

import UIKit
import Proposer
import ContactsUI
import AddressBookUI

class PhoneChargeViewController: BaseViewController, UITextFieldDelegate,
CNContactPickerDelegate, Dimmable {

    @IBOutlet private weak var textField: UITextField!
    private let contacts: PrivateResource = .Contacts
    @IBOutlet private var buttons: [UIButton]!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Method
    
    @IBAction func chooseContact() {
        proposeToAccess(contacts, agreed: {
            let address = CNContactPickerViewController()
            address.displayedPropertyKeys = [ABPersonPhoneNumbersProperty]
            address.delegate = self
            self.presentViewController(address, animated: true, completion: nil)
            }) {
               self.displayCantAddContactAlert()
        }
    }
    
    func displayCantAddContactAlert() {
        let cantAddContactAlert = UIAlertController(title: "无法访问联系人",
            message: "允许我们你的联系人\n以便选择电话号码",
            preferredStyle: .Alert)
        cantAddContactAlert.addAction(UIAlertAction(title: "修改设置",
            style: .Default,
            handler: { action in
                if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
        }))
        cantAddContactAlert.addAction(UIAlertAction(title: "好的", style: .Cancel, handler: nil))
        presentViewController(cantAddContactAlert, animated: true, completion: nil)
    }
    
    @IBAction func chargeHandle(sender: UIButton) {
        sender.selected = true
        for button in buttons where button.tag != sender.tag {
            button.selected = false
        }
        performSegueWithIdentifier(R.segue.phoneChargeViewController.showPaymentVC, sender: nil)
    }
    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        dim(.In, coverNavigationBar: true)
    }
    
    @IBAction func unwindFromSecondary(segue: UIStoryboardSegue) {
        dim(.Out, coverNavigationBar: true)
        buttons.forEach { (button) -> Void in
            button.selected = false
        }
    }
    
    // MARK: Contact Picker Delegate
    
    func contactPicker(picker: CNContactPickerViewController, didSelectContactProperty contactProperty: CNContactProperty) {
        let value = contactProperty.contact.phoneNumbers[0]
        guard let phone = value.value as? CNPhoneNumber else {
            return
        }
        var number = phone.stringValue as NSString
        number = number.stringByReplacingOccurrencesOfString(" ", withString: "")
        number = number.stringByReplacingOccurrencesOfString("-", withString: "")
        number = number.stringByReplacingOccurrencesOfString("+", withString: "")
        if number.length > 11 {
            if number.hasPrefix("86") {
                number = number.substringFromIndex(2)
            } else if number.hasPrefix("086") {
                number = number.substringFromIndex(3)
            } else {
                
            }
        }
        if number.length == 11 {
            let formatterNumber = NSMutableString(string: number)
            formatterNumber.insertString(" ", atIndex: 7)
            formatterNumber.insertString(" ", atIndex: 4)
            textField.text = formatterNumber as String
        }
        
    }

    // MARK: Text Field Delegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        let components = newString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        
        let decimalString: String = components.joinWithSeparator("")
        let length = decimalString.characters.count
        let decimalStr = decimalString as NSString
        
        if length > 0 {
            let hasLeadingOne = decimalStr.substringToIndex(1) ==  "1"
            
            if !hasLeadingOne {
                textField.shakeIt()
                return false
            }
        }
        
        if length > 1 {
            let secondNumber = decimalStr.substringWithRange(NSRange(location: 1, length: 1))
            
            if secondNumber != "3" && secondNumber != "5" && secondNumber != "7" && secondNumber != "8" {
                textField.shakeIt()
                return false
            }
        }

        if length == 0 || length > 11 {
            let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
            if newLength > 11 {
                textField.shakeIt()
                return false
            } else {
                return true
            }
        }
        var index = 0 as Int
        let formattedString = NSMutableString()
        
        if (length - index) > 3 {
            let areaCode = decimalStr.substringWithRange(NSRange(location: index, length: 3))
            formattedString.appendFormat("%@ ", areaCode)
            index += 3
        }
        
        if length - index > 4 {
            let prefix = decimalStr.substringWithRange(NSRange(location: index, length: 4))
            formattedString.appendFormat("%@ ", prefix)
            index += 4
        }
        
        let remainder = decimalStr.substringFromIndex(index)
        formattedString.appendString(remainder)
        textField.text = formattedString as String
        return false
    }

}

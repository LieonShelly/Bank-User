//
//  ViewExtension.swift
//  Bank
//
//  Created by Koh Ryu on 11/23/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//
// swiftlint:disable force_unwrapping

import UIKit
import Foundation
import Eureka
import Kingfisher
import Device

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            } else {
                return nil
            }
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
}

extension UINavigationItem {
    @IBInspectable var localizedKey: String? {
        set {
            guard let newValue = newValue else { return }
            title = NSLocalizedString(newValue, comment: "")
        }
        get { return title }
    }
}

extension UILabel {
    @IBInspectable var localizedKey: String? {
        set {
            guard let newValue = newValue else { return }
            text = NSLocalizedString(newValue, comment: "")
        }
        get { return text }
    }
}

extension UIButton {
    @IBInspectable var localizedKey: String? {
        set {
            guard let newValue = newValue else { return }
            setTitle(NSLocalizedString(newValue, comment: ""), for: .normal)
        }
        get { return titleLabel?.text }
    }
}

extension UITextField {
    @IBInspectable var localizedKey: String? {
        set {
            guard let newValue = newValue else { return }
            placeholder = NSLocalizedString(newValue, comment: "")
        }
        get { return placeholder }
    }
}

extension UITableView {
    
    /**
     显示或者隐藏 Table View 底部的 银行 logo
     
     - parameter hidden: true 隐藏，false 显示
     */
    func configBackgroundView(_ hidden: Bool = false) {
        backgroundColor = UIColor(hex: 0xf5f5f5)
//        self.separatorColor = UIColor(hex: 0xe5e5e5)
//        let view = UIView(frame: CGRect())
//        view.backgroundColor = UIColor(hex: CustomKey.Color.ViewBackgroundColor)
//
//        let bottomLogo = R.image.bottom_logo()
//        let bottomLogoView = UIImageView(image: bottomLogo)
//        bottomLogoView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(bottomLogoView)
//        
//        view.addConstraint(NSLayoutConstraint(item: bottomLogoView, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0))
//        view.addConstraint(NSLayoutConstraint(item: bottomLogoView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: -Const.TableView.LogoFooterGap))
//        
//        backgroundView = view
    }

}

extension UICollectionView {
    /**
     显示或者隐藏 Table View 底部的 银行 logo
     
     - parameter hidden: true 隐藏，false 显示
     */
    func configBackgroundView(_ hidden: Bool = false) {
        self.backgroundColor = UIColor(hex: 0xf5f5f5)
//        let view = UIView(frame: CGRect())
//        view.backgroundColor = UIColor(hex: CustomKey.Color.ViewBackgroundColor)
//        
//        let bottomLogo = R.image.bottom_logo()
//        let bottomLogoView = UIImageView(image: bottomLogo)
//        bottomLogoView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(bottomLogoView)
//        
//        view.addConstraint(NSLayoutConstraint(item: bottomLogoView, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0))
//        view.addConstraint(NSLayoutConstraint(item: bottomLogoView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: -Const.TableView.LogoFooterGap))
//        
//        backgroundView = view
    }

}

extension UITextField {
    
    /**
     Shake it baby!
     */
    func shakeIt() {
        let offset = self.bounds.size.width / 30
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - offset, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + offset, y: self.center.y))
        self.layer.add(animation, forKey: "position")
    }
}

extension UILabel {

    /**
     给 label 设置数字与单位
     
     - parameter amount:           要显示的数字
     - parameter color:            label整体的文字颜色 默认 "橙色 ff6400"
     - parameter amountFontSize:   数字部分的字体大小
     - parameter unitFontSize:     单位的字体大小
     - parameter strikethrough:    是否需要整体的删除线
     - parameter fontWeight:       字重
     - parameter unit:             单位文字 默认 "元"
     - parameter decimalPlace:     保留小数位数 四舍五入
     - parameter useBigUnit:       使用大额金钱单位 仅支持 元->万元
     */
    func amountWithUnit(_ amount: Float, color: UIColor = UIColor(hex: 0xff6400), amountFontSize: CGFloat, unitFontSize: CGFloat, strikethrough: Bool = false, fontWeight: CGFloat? = nil, unit: String = "元", decimalPlace: Int? = nil, useBigUnit: Bool = false) {
        let str = String(format: "%.2f", amount)
        guard let num = Float(str) else { return }
        if num == roundf(num) {
            let attributedText = NSAttributedString(amountNumber: num, color: color, amountFontSize: amountFontSize, unitFontSize: unitFontSize, strikethrough: strikethrough, fontWeight: fontWeight, unit: unit, decimalPlace: 0, useBigUnit: useBigUnit)
            self.attributedText = attributedText
        } else if num*10 == roundf(num*10) {
            let attributedText = NSAttributedString(amountNumber: num, color: color, amountFontSize: amountFontSize, unitFontSize: unitFontSize, strikethrough: strikethrough, fontWeight: fontWeight, unit: unit, decimalPlace: 1, useBigUnit: useBigUnit)
            self.attributedText = attributedText
        } else {
            let attributedText = NSAttributedString(amountNumber: num, color: color, amountFontSize: amountFontSize, unitFontSize: unitFontSize, strikethrough: strikethrough, fontWeight: fontWeight, unit: unit, decimalPlace: 2, useBigUnit: useBigUnit)
            self.attributedText = attributedText
        }
    }
    
    /**
     label 显示日期时间
     
     - parameter date:   需要显示的日期
     - parameter format: 日期格式 默认 yyyy-MM-dd
     */
    func timeWithFormat(_ date: Date?, format: String = "yyyy-MM-dd") {
        guard let time = date else {
            return
        }
        let dateFmt = DateFormatter()
        dateFmt.timeZone = TimeZone.current
        dateFmt.dateFormat = format
        self.text = dateFmt.string(from: time)
    }
}

extension UINavigationBar {
    
    func hideBottomHairline() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(self)
        navigationBarImageView?.isHidden = true
    }
    
    func showBottomHairline() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(self)
        navigationBarImageView?.isHidden = false
    }
    
    fileprivate func hairlineImageViewInNavigationBar(_ view: UIView) -> UIImageView? {
        if view.isKind(of: UIImageView.self) && view.bounds.height <= 1.0 {
            guard let view = view as? UIImageView else {
                return nil
            }
            return view
        }
        
        let subviews = (view.subviews as [UIView])
        for subview: UIView in subviews {
            if let imageView: UIImageView = hairlineImageViewInNavigationBar(subview) {
                return imageView
            }
        }
        return nil
    }
    
}

extension FormViewController {
    override func validatePhoneNumber(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        let components = newString.components(separatedBy: CharacterSet.decimalDigits.inverted)
        let decimalString: String = components.joined(separator: "")
        let length = decimalString.characters.count
        let decimalStr = decimalString as NSString
        if length > 0 {
            let hasLeadingOne = decimalStr.substring(to: 1) ==  "1"
            
            if !hasLeadingOne {
                textField.shakeIt()
                return false
            }
        }
        
        if length > 1 {
            let secondNumber = decimalStr.substring(with: NSRange(location: 1, length: 1))
            
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
            let areaCode = decimalStr.substring(with: NSRange(location: index, length: 3))
            formattedString.appendFormat("%@ ", areaCode)
            index += 3
        }
        
        if length - index > 4 {
            let prefix = decimalStr.substring(with: NSRange(location: index, length: 4))
            formattedString.appendFormat("%@ ", prefix)
            index += 4
        }
        
        let remainder = decimalStr.substring(from: index)
        formattedString.append(remainder)
        let result = formattedString as String
        textField.text = result
        form.setValues(["mobile": result])
        return false
    }
}

extension UIViewController {
    func validatePhoneNumber(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        let components = newString.components(separatedBy: CharacterSet.decimalDigits.inverted)
        let decimalString: String = components.joined(separator: "")
        let length = decimalString.characters.count
        let decimalStr = decimalString as NSString
        if length > 0 {
            let hasLeadingOne = decimalStr.substring(to: 1) ==  "1"
            
            if !hasLeadingOne {
                textField.shakeIt()
                return false
            }
        }
        
        if length > 1 {
            let secondNumber = decimalStr.substring(with: NSRange(location: 1, length: 1))
            
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
            let areaCode = decimalStr.substring(with: NSRange(location: index, length: 3))
            formattedString.appendFormat("%@ ", areaCode)
            index += 3
        }
        
        if length - index > 4 {
            let prefix = decimalStr.substring(with: NSRange(location: index, length: 4))
            formattedString.appendFormat("%@ ", prefix)
            index += 4
        }
        
        let remainder = decimalStr.substring(from: index)
        formattedString.append(remainder)
        textField.text = formattedString as String
        return false
    }
    
    func validatePhoneNumberWithoutSpace(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        let components = newString.components(separatedBy: CharacterSet.decimalDigits.inverted)
        let decimalString: String = components.joined(separator: "")
        let length = decimalString.characters.count
        let decimalStr = decimalString as NSString
        if length > 0 {
            let hasLeadingOne = decimalStr.substring(to: 1) ==  "1"
            
            if !hasLeadingOne {
                textField.shakeIt()
                return false
            }
        }
        
        if length > 1 {
            let secondNumber = decimalStr.substring(with: NSRange(location: 1, length: 1))
            
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
        let index = 0 as Int
        let formattedString = NSMutableString()
        let remainder = decimalStr.substring(from: index)
        formattedString.append(remainder)
        textField.text = formattedString as String
        return false
    }

}

extension UIImageView {
    func setImage(with url: URL?, placeholderImage: UIImage? = nil) {
        var urlString = url?.absoluteString
        var scale: CGFloat = 2
        if Device.size() > .screen4_7Inch {
            scale = 3
        }
        let maxValue = max(frame.width, frame.height) * scale
        if maxValue <= 400 {
            urlString?.append("_thumb")
        } else if maxValue > 800 {
            urlString?.append("_large")
        } else {
            urlString?.append("_small")
        }
        let tempMode = self.contentMode
        guard let str = urlString, let _url = URL(string: str) else { return }
        if !ImageCache.default.isImageCached(forKey: _url.cacheKey).cached {
            self.contentMode = .scaleAspectFit
        }
        
        self.kf.setImage(with: _url, placeholder: placeholderImage) { (image, _, _, _) in
            if image != nil {
                self.contentMode = tempMode
            }
        }
    }
}

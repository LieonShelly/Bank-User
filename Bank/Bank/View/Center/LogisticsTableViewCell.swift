//
//  LogisticsTableViewCell.swift
//  Bank
//
//  Created by 杨锐 on 16/8/11.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//
// swiftlint:disable private_outlet

import UIKit

class LogisticsTableViewCell: UITableViewCell {
    enum Position {
        case top
        case center
        case bottom
        case one
    }
    
    @IBOutlet fileprivate weak var theViewHeight: NSLayoutConstraint!
    @IBOutlet fileprivate weak var theView: UIView!
    @IBOutlet fileprivate weak var dateLabel: UILabel!
    @IBOutlet fileprivate weak var spotImageView: UIImageView!
    @IBOutlet fileprivate weak var bottomLineView: UIView!
    @IBOutlet fileprivate weak var topLineView: UIView!
    @IBOutlet fileprivate weak var textView: UITextView!
    var position: Position = .one
    var clickHanleBlock: ((_ tel: String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configInfo(_ data: Track) {
        textView.contentSize = CGSize(width: 0, height: 0)
//        data.acceptStation = "上的烦恼卡迪夫那块地方拿快递发看到你发快递费那客服那地方卡法IE跟那女爱你的份13981163819"
        if let string = data.acceptStation {
            let phoneRange = checkPhoneForString(string)
            let attributedString = NSMutableAttributedString(string: string)
            let stringRange = NSRange(location: 0, length: attributedString.length)
            //设置一般的文字为15号
            attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 15), range: stringRange)
            switch position {
            case .top:
                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(hex: 0x1c1c1c), range: stringRange)
                topLineView.isHidden = true
                bottomLineView.isHidden = false
                spotImageView.image = R.image.icon_spot()
            case .center:
                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(hex: 0x666666), range: stringRange)
                topLineView.isHidden = false
                bottomLineView.isHidden = false
                spotImageView.image = R.image.icon_spot1()
            case .bottom:
                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(hex: 0x666666), range: stringRange)
                topLineView.isHidden = false
                bottomLineView.isHidden = true
                spotImageView.image = R.image.icon_spot1()
            case .one:
                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(hex: 0x1c1c1c), range: stringRange)
                topLineView.isHidden = true
                bottomLineView.isHidden = true
                spotImageView.image = R.image.icon_spot()
            }
            //电话号码加下划线
            attributedString.addAttribute(NSUnderlineStyleAttributeName, value: 1, range: phoneRange)
            //电话号码字体为16号
            attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 16), range: phoneRange)
            //电话号码颜色
            attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(hex: 0x00a8fe), range: phoneRange)
            // 行间距为10
            let paraStyle = NSParagraphStyle()
            paraStyle.setValue(10, forKey: "lineSpacing")
            attributedString.addAttribute(NSParagraphStyleAttributeName, value: paraStyle, range: NSRange(location: 0, length: attributedString.length))
            var rect = textView.frame
            rect.size.width = UIScreen.main.bounds.width - 58
            textView.frame = rect
            textView.contentSize = textView.frame.size
            textView.attributedText = attributedString
            theViewHeight.constant = textView.contentSize.height
        }
        if let date = data.acceptTime {
            dateLabel.text = date.toString("yyyy-MM-dd HH:mm:ss")
        }
    }
    
    fileprivate func checkPhoneForString(_ string: String) -> NSRange {
        // 电话号码的正则表达式
        let number = "[1-9][0-9]{4,14}"
        
        do {
            let regex = try NSRegularExpression(pattern: number, options: .caseInsensitive)
            let resule = regex.matches(in: string, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange(location: 0, length: string.characters.count))
            for check in resule {
                return check.range
            }
        } catch {
            
        }
        return NSRange(location: 0, length: 0)
    }
    
}

extension LogisticsTableViewCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if let block = clickHanleBlock {
            let urlString = String(describing: URL)
            let tel = NSString(string: urlString).replacingCharacters(in: NSRange(location: 0, length: 4), with: "")
            block(tel)
        }
        return true
    }
}

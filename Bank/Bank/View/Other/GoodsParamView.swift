//
//  GoodsParamView.swift
//  Bank
//
//  Created by 杨锐 on 2016/10/26.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class GoodsParamView: UIView {
    
    var selectedButton: UIButton?
    var valueArray: [GoodsProperty] = []
    var title: GoodsProperty!
    var packView: UIView!
    var buttonView: UIView!
    var isSelected: Bool = false
    var buttonHandleBlock: ((_ title: GoodsProperty, _ property: GoodsProperty, _ isSelectd: Bool?) -> Void)?
    
    init(frame: CGRect, title: GoodsProperty, valueArray: [GoodsProperty]) {
        super.init(frame: frame)
        self.frame = frame
        self.title = title
        self.valueArray.append(contentsOf: valueArray)
        self.createRankView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 创建选择规格的视图
    func createRankView() {
        packView = UIView(frame: frame)
        packView.frame.origin.y = 0
        
        let lineView = UIView(frame: CGRect(x: 17, y: 0, width: screenWidth - 17, height: 0.7))
        lineView.backgroundColor = UIColor(hex: 0xe5e5e5)
        packView.addSubview(lineView)
        
        let titleLabel = UILabel(frame: CGRect(x: 20, y: 10, width: 250, height: 25))
        titleLabel.text = title.title
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.textColor = UIColor(hex: 0x666666)
        packView.addSubview(titleLabel)
        
        buttonView = UIView(frame: CGRect(x: 0, y: titleLabel.frame.maxY, width: screenWidth, height: 40))
        packView.addSubview(buttonView)
        
        var count: CGFloat = 0
        var buttonWidth: CGFloat = 0
        var viewHeight: CGFloat = 0
        for i in 0..<valueArray.count {
            let buttonTitle = valueArray[i].value
            let button = UIButton(type: .custom)
            button.backgroundColor = UIColor.white
            button.setTitleColor(UIColor(hex: 0x666666), for: .normal)
            button.setTitleColor(UIColor(hex: 0x00a8fe), for: .selected)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            button.setTitle(buttonTitle, for: .normal)
            button.tag = i
            button.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
            
            button.layer.cornerRadius = 3
            button.layer.masksToBounds = true
            button.layer.borderColor = UIColor(hex: 0xe5e5e5).cgColor
            button.layer.borderWidth = 1
            
            if valueArray[i].value == self.title.value {
                selectedButton = button
                button.isSelected = true
            } else {
                button.isSelected = false
            }
            
            let dic = [NSFontAttributeName: UIFont.systemFont(ofSize: 14)]
            let btnSize = NSString(string: buttonTitle).size(attributes: dic)
            var rect = button.frame
            rect.size.width = btnSize.width + 15
            rect.size.height = btnSize.height + 12
            
            rect.size.width = rect.size.width < 70 ? 70 : rect.size.width
            if i == 0 {
                rect.origin.x = 20
                buttonWidth += rect.maxX
            } else {
                buttonWidth += rect.maxX + 20
                if buttonWidth > screenWidth {
                    count += 1
                    rect.origin.x = 20
                    buttonWidth = rect.maxX
                } else {
                    rect.origin.x = buttonWidth - rect.width
                }
            }
            rect.origin.y = count * (rect.height + 10) + 10
            viewHeight = rect.maxY + 10
            button.frame = rect
            buttonView.addSubview(button)
        }
        var buttonViewRect = buttonView.frame
        buttonViewRect.size.height = viewHeight
        buttonView.frame = buttonViewRect
        
        var packViewRect = packView.frame
        packViewRect.size.height = buttonView.frame.height + titleLabel.frame.maxY
        packView.frame = packViewRect
        
        var rect = self.frame
        rect.size.height = packView.frame.size.height
        self.frame = rect
        
        addSubview(packView)
    }
    
    /// 重新加载button的状态
    ///
    /// - Parameter propertys: 商品规格数组
    func reloadViewWithData(propertys: [GoodsProperty], isSelected: Bool?) {
        for view in buttonView.subviews {
            guard let button = view as? UIButton else {
                return
            }
            if propertys.contains(where: { (pro) -> Bool in
                if pro.value == button.titleLabel?.text && pro.id == self.title.id {
                    return true
                }
                return false
            }) == true {
                button.backgroundColor = UIColor.white
                button.isEnabled = true
                button.layer.borderColor = button.isSelected == true ?
                    UIColor(hex: 0xe00a8fe).cgColor : UIColor(hex: 0xe5e5e5).cgColor
            } else {
                button.backgroundColor = UIColor(hex: 0xe5e5e5)
                button.isEnabled = false
                button.isSelected = false
                button.layer.borderColor = UIColor(hex: 0xe5e5e5).cgColor
            }
        }
    }
    
    /// 按钮点击事件
    @objc fileprivate func buttonClick(_ sender: UIButton) {
        if sender.tag == selectedButton?.tag {
            selectedButton?.isSelected = selectedButton?.isSelected == true ? false : true
        } else {
            selectedButton?.isSelected = false
            selectedButton?.layer.borderColor = UIColor(hex: 0xe5e5e5).cgColor
            sender.isSelected = !sender.isSelected
            selectedButton = sender
        }
        if selectedButton?.isSelected == true {
            selectedButton?.layer.borderColor = UIColor(hex: 0x00a8fe).cgColor
        } else {
            selectedButton?.layer.borderColor = UIColor(hex: 0xe5e5e5).cgColor
        }
        if let selected = selectedButton?.isSelected {
            self.isSelected = selected
        }
        if let block = buttonHandleBlock {
            block(title, valueArray[sender.tag], selectedButton?.isSelected)
        }
    }
}

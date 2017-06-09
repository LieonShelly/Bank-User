//
//  MenuView.swift
//  Bank
//
//  Created by yang on 16/2/25.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class MenuView: UIView {
    var menuTableView: UITableView!
    var imagesArray: [UIImage?] = []
    var dataSorceArray: [String] = []
    
    //动画时间
    var comeTime: TimeInterval = 0.3
    var goTime: TimeInterval = 0.3
    var actionBlock: ((_ index: NSInteger) -> Void)?
    var blackView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        blackView = UIView(frame: frame)
        blackView.backgroundColor = UIColor.clear
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.remove))
        blackView.addGestureRecognizer(tap)
        addSubview(blackView)
        // tableView
        menuTableView = UITableView(frame: CGRect(x: self.bounds.width - 133, y: 60, width: 123, height: CGFloat(imagesArray.count) * 40), style: .plain)
        menuTableView?.delegate = self
        menuTableView?.dataSource = self
        menuTableView?.layer.cornerRadius = 5
        menuTableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        addSubview(menuTableView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func remove() {
        self.menuTableView.alpha = 0
        self.alpha = 0
        removeFromSuperview()
    }
    
    func showTableView() {
        menuTableView.reloadData()
        self.menuTableView.alpha = 1
        self.alpha = 1
    }
    
    // 画三角形
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.move(to: CGPoint(x: self.bounds.width - 28, y: 50))
        context.addLine(to: CGPoint(x: self.bounds.width - 36, y: 60))
        context.addLine(to: CGPoint(x: self.bounds.width - 20, y: 60))
        context.addLine(to: CGPoint(x: self.bounds.width - 28, y: 50))
        UIColor.white.set()
        context.fillPath()
    }
    
}

extension MenuView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifile = "cell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: identifile)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifile)
        }
        cell?.imageView?.image = imagesArray[indexPath.row]
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell?.textLabel?.textColor = UIColor(hex: 0x666666)
        cell?.textLabel?.text = dataSorceArray[indexPath.row]
        cell?.selectionStyle = .none
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSorceArray.count
    }

}

extension MenuView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        remove()
        if let block = actionBlock {
            block(indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

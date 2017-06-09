//
//  VerticalCycleView.swift
//  Bank
//
//  Created by yang on 16/4/27.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class VerticalCycleView: UIView {
    
    @IBInspectable var textColor: UIColor = UIColor.darkGray
    @IBInspectable var contentBackColor: UIColor = UIColor.white
    private let font: UIFont = UIFont.systemFont(ofSize: 13)

    var contentScrollView: UIScrollView!
    var timer: Timer!
    var timeInterval: TimeInterval = 3
    var currentLabel: UILabel!
    var lastLabel: UILabel!
    var nextLabel: UILabel!
    var currentIndex: Int = 0
    var clickHandleBlock: ((_ index: Int) -> Void)?
    var titleArray: [String] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        addGestureRecognizer(tap)
        contentScrollView = UIScrollView(frame: self.bounds)
        contentScrollView.contentSize = CGSize(width: frame.width, height: CGFloat(titleArray.count) * frame.height)
        contentScrollView.backgroundColor = contentBackColor
        contentScrollView.isPagingEnabled = true
        contentScrollView.isScrollEnabled = false
        contentScrollView.showsVerticalScrollIndicator = false
        contentScrollView.showsHorizontalScrollIndicator = false
        contentScrollView.delegate = self
        contentScrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentScrollView)
        contentScrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        contentScrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        contentScrollView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        contentScrollView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        lastLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        lastLabel.textColor = textColor
        lastLabel.font = font
        lastLabel.numberOfLines = 1
        lastLabel.translatesAutoresizingMaskIntoConstraints = false
//        lastLabel.autoresizingMask = [.FlexibleWidth]
        contentScrollView.addSubview(lastLabel)
        lastLabel.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor).isActive = true
        lastLabel.topAnchor.constraint(equalTo: contentScrollView.topAnchor).isActive = true
        lastLabel.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        lastLabel.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        currentLabel = UILabel(frame: CGRect(x: 0, y: frame.height, width: frame.width, height: frame.height))
        currentLabel.textColor = textColor
        currentLabel.numberOfLines = 1
        currentLabel.font = font
        currentLabel.translatesAutoresizingMaskIntoConstraints = false
        //        currentLabel.autoresizingMask = [.FlexibleWidth]
        contentScrollView.addSubview(currentLabel)
        currentLabel.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor).isActive = true
        currentLabel.topAnchor.constraint(equalTo: lastLabel.bottomAnchor).isActive = true
        currentLabel.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        currentLabel.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        nextLabel = UILabel(frame: CGRect(x: 0, y: frame.height * 2, width: frame.width, height: frame.height))
        nextLabel.textColor = textColor
        nextLabel.numberOfLines = 1
        nextLabel.font = font
        nextLabel.translatesAutoresizingMaskIntoConstraints = false
//        nextLabel.autoresizingMask = [.FlexibleWidth]
        contentScrollView.addSubview(nextLabel)
        nextLabel.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor).isActive = true
        nextLabel.topAnchor.constraint(equalTo: currentLabel.bottomAnchor).isActive = true
        nextLabel.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        nextLabel.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    func tapAction() {
        if let block = clickHandleBlock {
            block(currentIndex)
        }
    }
    
    func setCycleScrollView(_ newsArray: [String]) {
        if newsArray.count < 3 {
            return
        }
        self.titleArray = newsArray
        setScrollViewOfLabel()
        contentScrollView.setContentOffset(CGPoint(x: 0, y: frame.height), animated: false)
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
            RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)

        }
        
    }
    
    //定时器方法
    func timerAction() {
        contentScrollView.setContentOffset(CGPoint(x: 0, y: frame.height * 2), animated: true)
    }
    
    // 循环设置Label
    func setScrollViewOfLabel() {
        currentLabel.text = titleArray[currentIndex]
        nextLabel.text = titleArray[getNextIndex(currentIndex: currentIndex)]
        lastLabel.text = titleArray[getLastIndex(currentIndex: currentIndex)]
    }
    
    // 得到上一个Label的下标
    func getLastIndex(currentIndex index: Int) -> Int {
        return index - 1 == -1 ? titleArray.count - 1 : index - 1
    }
    
    // 得到下一个Label的下标
    func getNextIndex(currentIndex index: Int) -> Int {
        return index + 1 < titleArray.count ? index + 1 : 0
    }

}

extension VerticalCycleView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        if offset == 0 {
            currentIndex = getLastIndex(currentIndex: currentIndex)
        } else if offset == frame.height * 2 {
            currentIndex = getNextIndex(currentIndex: currentIndex)
        }
        // 重新布局Label
        setScrollViewOfLabel()
        scrollView.setContentOffset(CGPoint(x: 0, y: frame.height), animated: false)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewDidEndDecelerating(contentScrollView)
    }

}

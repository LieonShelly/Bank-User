//
//  StarsView.swift
//  Bank
//
//  Created by yang on 16/3/7.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class StarsView: UIView {
    fileprivate var startBackgroundView: UIView!
    fileprivate var startForegroundView: UIView!
    
    var isNormal = false
    var grade: Float = 0
    
    func conformsStarView(_ emptyImage: UIImage, starImage: UIImage) {
        if isNormal == false {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapAction(_:)))
            addGestureRecognizer(tap)
            let pan = UIPanGestureRecognizer(target: self, action: #selector(self.tapAction(_:)))
            addGestureRecognizer(pan)
        }
        startBackgroundView = buildStarViewWithImage(emptyImage)
        startForegroundView = buildStarViewWithImage(starImage)
        startForegroundView.clipsToBounds = true
        addSubview(startBackgroundView)
        addSubview(startForegroundView)
        if grade != 0 {
            startForegroundView.frame = CGRect(x: 0.0, y: 0.0, width: (25+10) * CGFloat(grade), height: 30.0)
        } else {
            startForegroundView.frame = CGRect(x: 0, y: 0, width: (25+10) * 5, height: 30)
        }
        
    }
    
    func buildStarViewWithImage(_ image: UIImage) -> UIView {
        let frame = bounds
        let view = UIView(frame: frame)
        for i in 0..<5 {
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: i * 25 + 10 * i, y: 5, width: 25, height: 24)
            view.addSubview(imageView)
        }
        return view
    }
    
    func tapAction(_ tap: UITapGestureRecognizer) {
        var point = tap.location(in: self)
        if point.x < 0 {
            point.x = 0
        }
        
        let X = Int(point.x / ((25+10)))
        startForegroundView.frame = CGRect(x: 0, y: 0, width: (X+1)*(25+10), height: 30)
        grade = Float(X + 1)
    }
    
}

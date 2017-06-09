//
//  ScanQRDrawView.swift
//  Bank
//
//  Created by 杨锐 on 2016/10/17.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class ScanQRDrawView: UIView {

    override func draw(_ rect: CGRect) {
        let contexteRef = UIGraphicsGetCurrentContext()
        let leftWidth: CGFloat = 50
        // 角长
        let length: CGFloat = 40
        
        contexteRef?.setStrokeColor(UIColor.white.cgColor)
        contexteRef?.setLineWidth(1)
        contexteRef?.addRect(CGRect(x: leftWidth, y: screenHeight * 0.25, width: scanWidth, height: scanHeight))
        contexteRef?.strokePath()
        
        let lineWidth: CGFloat = 4
        let halfLine = lineWidth/2
        
        contexteRef?.setStrokeColor(UIColor.white.cgColor)
        contexteRef?.setLineWidth(lineWidth)
        // 左上角水平线
        
        contexteRef?.move(to: CGPoint(x: leftWidth - halfLine, y: screenHeight * 0.25))
        contexteRef?.addLine(to: CGPoint(x: leftWidth + length, y: screenHeight * 0.25))
        // 左上角垂直线
        contexteRef?.move(to: CGPoint(x: leftWidth, y: screenHeight * 0.25 - halfLine))
        contexteRef?.addLine(to: CGPoint(x: leftWidth, y: screenHeight * 0.25 + length))
        // 左下角水平线
        contexteRef?.move(to: CGPoint(x: leftWidth - halfLine, y: screenHeight * 0.25 + scanHeight))
        contexteRef?.addLine(to: CGPoint(x: leftWidth + length, y: screenHeight * 0.25 + scanHeight))
        // 左下角垂直线
        contexteRef?.move(to: CGPoint(x: leftWidth, y: screenHeight * 0.25 + scanHeight + halfLine))
        contexteRef?.addLine(to: CGPoint(x: leftWidth, y: screenHeight * 0.25 + scanHeight - length))
        // 右上角水平线
        contexteRef?.move(to: CGPoint(x: screenWidth - leftWidth + halfLine, y: screenHeight * 0.25))
        contexteRef?.addLine(to: CGPoint(x: screenWidth - leftWidth - length, y: screenHeight * 0.25))
        // 右上角垂直线
        contexteRef?.move(to: CGPoint(x: screenWidth - leftWidth, y: screenHeight * 0.25 - halfLine))
        contexteRef?.addLine(to: CGPoint(x: screenWidth - leftWidth, y: screenHeight * 0.25 + length))
        // 右下角水平线
        contexteRef?.move(to: CGPoint(x: screenWidth - leftWidth + halfLine, y: screenHeight * 0.25 + scanHeight))
        contexteRef?.addLine(to: CGPoint(x: screenWidth - leftWidth - length, y: screenHeight * 0.25 + scanHeight))
        // 右下角垂直线
        contexteRef?.move(to: CGPoint(x: screenWidth - leftWidth, y: screenHeight * 0.25 + scanHeight + halfLine))
        contexteRef?.addLine(to: CGPoint(x: screenWidth - leftWidth, y: screenHeight * 0.25 + scanHeight - length))
        
        contexteRef?.strokePath()
    }

}

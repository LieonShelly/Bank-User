//
//  EAccountDetailViewController.swift
//  Bank
//
//  Created by Koh Ryu on 16/5/3.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import LKPageMenu

class EAccountDetailViewController: BaseViewController {
    
    private var pageMenu: CAPSPageMenu?
    private var listType: ListVCType = .EAccountDetail
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenu()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupMenu() {
        var controllerArray: [BaseViewController] = []
        let titleArray: [String] = listType.titles
        
        for i in 0 ..< titleArray.count {
            if let controller = listType.instanceController {
                controller.title = titleArray[i]
                controllerArray.append(controller)
            }
        }
        let parameters: [CAPSPageMenuOption] = [
            .CenterMenuItems(false),
            .AddBottomMenuHairline(true),
            .BottomMenuHairlineColor(UIColor.colorFromHex(CustomKey.Color.LineColor)),
            .ViewBackgroundColor(UIColor.clearColor()),
            .ScrollMenuBackgroundColor(UIColor.whiteColor()),
            .MenuItemWidthBasedOnTitleTextWidth(false),
            .ShowSettingButton(R.image.btn_the_custom()),
            .MenuItemSeparatorPercentageHeight(0.0),
            .MenuHeight(40),
            .SelectionIndicatorHeight(2.5),
            .SelectionIndicatorColor(UIColor.colorFromHex(CustomKey.Color.MainBlueColor)),
            .SelectedMenuItemLabelColor(UIColor.colorFromHex(CustomKey.Color.MainBlueColor)),
            .UnselectedMenuItemLabelColor(UIColor.colorFromHex(0x666666)),
            .MenuItemFont(UIFont.systemFontOfSize(16.0))
        ]
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(origin: CGPoint(), size: self.view.frame.size), pageMenuOptions: parameters)
        pageMenu?.delegate = self
        if let view = pageMenu?.view {
            self.view.addSubview(view)
        }
    }

}

extension EAccountDetailViewController: CAPSPageMenuDelegate {
    func settingButtonHandle() {
        performSegueWithIdentifier(R.segue.eAccountDetailViewController.showFilterVC, sender: nil)
    }
}

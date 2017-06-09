//
//  LocationRow.swift
//  Bank
//
//  Created by Koh Ryu on 16/4/6.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import Foundation
import Eureka

final class LocationRow: SelectorRow<PushSelectorCell<Branch>, ChooseBranchViewController>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = .show(controllerProvider: ControllerProvider.callback { return ChooseBranchViewController() { _ in } }, onDismiss: { controller in _ = controller.navigationController?.popViewController(animated: true) })
        displayValueFor = {
            guard let branch = $0 else { return "" }
            return branch.name
        }
    }
}

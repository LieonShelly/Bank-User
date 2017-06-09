//
//  InputAccessoryToolbar.swift
//  Bank
//
//  Created by Koh Ryu on 11/25/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//

import UIKit

typealias DoneHandleBlock = () -> Void
typealias CancelHandleBlock = () -> Void

class InputAccessoryToolbar: UIToolbar {
    
    var doneHandleBlock: DoneHandleBlock?
    var cancelHandleBlock: CancelHandleBlock?
    
    @IBAction func doneHandle() {
        if let block = doneHandleBlock {
            block()
        }
    }
    
    @IBAction func cancelHandle() {
        if let block = cancelHandleBlock {
            block()
        }
    }
}

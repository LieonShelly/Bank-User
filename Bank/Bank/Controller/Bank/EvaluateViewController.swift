//
//  EvaluateViewController.swift
//  Bank
//
//  Created by lieon on 16/8/9.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD

let chatEndMessageIDPath = "chatEndMessage".cacheDir()

class EvaluateViewController: BaseViewController {
    var chatDetailId: String = ""
    var grade: Int = 0
    @IBOutlet weak fileprivate var didviderLine1: UIView!
    @IBOutlet weak fileprivate var dividerLine0: UIView!
    @IBOutlet fileprivate var startButtons: [UIButton]!
    
    @IBAction func starButtonClick(_ sender: UIButton) {
        switch sender.tag {
            case 1: oneStar()
            case 2: twoStar()
            case 3: threeStar()
            case 4: fourStar()
            case 5: fiveStar()
        default:
            break
        }
    }
    
    @IBAction func enterButonClick(_ sender: UIButton) {
        let cachedID = cachedChatednMessageID()
        if cachedID == chatDetailId {
        
            MBProgressHUD.errorMessage(view: view, message: R.string.localizable.mbprogressHud_have_commented_service())
            self.dismiss(animated: true, completion: nil)
            return
        }
        if grade == 0 {
            MBProgressHUD.errorMessage(view: view, message: R.string.localizable.mbprogressHud_please_score())
            return
        }
        let param = BulterEvaluateParamter()
        param.grade = grade
        param.chatEndMessageID = chatDetailId
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint(endpoint: ButlerPath.review, param: param))
        req.then { (value) -> Void in
            self.dismiss(animated: true, completion: nil)
        }.catch { (error) in
            if let err = error as? AppError {
                MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
            }
        }
        saveChatEndMessageID(param.chatEndMessageID)
        
    }
    
    @IBAction func cancelButtonClick(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    fileprivate func setup() {
        print(startButtons.count)
        didviderLine1.backgroundColor = UIColor.colorFromHex(0xd2d2d2)
        dividerLine0.backgroundColor = UIColor.colorFromHex(0xd2d2d2)
      
    }
    
    fileprivate func oneStar() {
      
       startButtons[0].isSelected = true
        startButtons[1].isSelected = false
        startButtons[2].isSelected = false
        startButtons[3].isSelected = false
        startButtons[4].isSelected = false
        grade = 1
    }
    
    fileprivate func twoStar() {
        oneStar()
        startButtons[1].isSelected = true
        grade = 2
    }
    
    fileprivate func threeStar() {
        twoStar()
        startButtons[2].isSelected = true
        grade = 3
    }
    
    fileprivate func fourStar() {
        threeStar()
        startButtons[3].isSelected = true
        grade = 4
    }
    
    fileprivate func fiveStar() {
        fourStar()
        startButtons[4].isSelected = true
        grade = 5
    }
    
    fileprivate func saveChatEndMessageID(_ messageID: String) {
        do {
            try (messageID as NSString).write(toFile: chatEndMessageIDPath, atomically: true, encoding: String.Encoding.utf8.rawValue)
        } catch {
            print(error)
        }
        
    }
    
    fileprivate func cachedChatednMessageID() -> String {
        
        do {
            let ID = try NSString(contentsOfFile: chatEndMessageIDPath, encoding: String.Encoding.utf8.rawValue)
            return ID as String
        } catch {
            print(error)
        }
        return ""
    }
}

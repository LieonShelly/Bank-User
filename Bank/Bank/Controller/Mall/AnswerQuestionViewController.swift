//
//  AnswerQuestionViewController.swift
//  Bank
//
//  Created by yang on 16/4/1.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD

class AnswerQuestionViewController: BaseViewController {

    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var footerView: UIView!
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    var advertiseID: String?
    var advertise: Advert?
    fileprivate var question: AdvertQuestion?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.configBackgroundView()
        tableView.tableFooterView = footerView
        tableView.allowsMultipleSelection = true
        tableView.rowHeight = 70.0
        tableView.register(R.nib.answerQuestionTableViewCell)
        navigationItem.hidesBackButton = true
        requestData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// 请求广告的答案数组
    fileprivate func requestData() {
        guard let adID = advertiseID else {
            return
        }
        MBProgressHUD.loading(view: view)
        let param = AdvertiseParameter()
        param.adID = adID
        let req: Promise<AdvertQuestionData> = handleRequest(Router.endpoint( AdvertisePath.question, param: param))
        req.then { (value) -> Void in
            self.question = value.data
            if self.question?.answerType == .radio {
                self.typeLabel.text = R.string.localizable.titleLabel_title_one_select()
            } else {
                self.typeLabel.text = R.string.localizable.titleLabel_title_multi_select()
            }
            if let title = value.data?.question, let _ = value.data?.answerType {
                self.titleLabel.text = title
            } else {
                self.titleLabel.text = value.data?.question
            }
            self.tableView.reloadData()
        }.always { 
            MBProgressHUD.hide(for: self.view, animated: true)
        }.catch { (error) in
            if let err = error as? AppError {
                MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
            }
        }
    }
    
    /// 回答问题
    ///
    /// - Parameter array: 选中的答案
    fileprivate func requestAnwsers(_ array: [AdvertAnswer]) {
        
        MBProgressHUD.loading(view: view)
        let param = AdvertiseParameter()
        param.answer = array.flatMap { return $0.answerID }
        param.adID = advertiseID
        
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( AdvertisePath.answer, param: param))
        req.then { [weak self] (value) -> Void in
            /*
             回答正确：弹框提示：回答正确！恭喜获得xx积分。并返回广告列表。
             • 回答错误：弹框提示：不对喔！“再看一遍”
             status=0 code=06090404 是回答错误，status＝1就回答正确
             */
            let point = self?.advertise?.point ?? 0
            let message = "回答正确！恭喜获得\(point)积分"
            let vc = UIAlertController(title: "", message: message, preferredStyle: .alert)
            vc.addAction(UIAlertAction(title: R.string.localizable.alertTitle_confirm(), style: .cancel, handler: { (action) in
                self?.performSegue(withIdentifier: R.segue.answerQuestionViewController.unwindAnswerSuccess, sender: nil)
            }))
            self?.present(vc, animated: true, completion: nil)
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    if err.errorCode.errorCode() == RequestErrorCode.answerWrong.errorCode() {
                        let message = R.string.localizable.alertTitle_wrong()
                        let vc = UIAlertController(title: R.string.localizable.alertTitle_nil(), message: message, preferredStyle: .alert)
                        vc.addAction(UIAlertAction(title: R.string.localizable.alertTitle_dont_look(), style: .default, handler: { (anction) in
                            self.performSegue(withIdentifier: R.segue.answerQuestionViewController.unwindAnswerSuccess, sender: nil)
                        }))
                        vc.addAction(UIAlertAction(title: R.string.localizable.alertTitle_look_agin(), style: .default, handler: { (action) in
                            self.performSegue(withIdentifier: R.segue.answerQuestionViewController.unwindFromAnswer, sender: nil)
                        }))
                        self.present(vc, animated: true, completion: nil)
                        self.tableView.reloadData()
                    } else {
                        MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                    }
                }
        }
    }
    
    @IBAction func closeHandle() {
        performSegue(withIdentifier: R.segue.answerQuestionViewController.unwindFromAnswer, sender: nil)
    }
    
    @IBAction func submitHandle() {
        guard let selectedIndex = tableView.indexPathsForSelectedRows else {
            MBProgressHUD.errorMessage(view: view, message: R.string.localizable.alertTitle_please_select_answer())
            return
        }
        let indexs = selectedIndex.map { return $0.row }
        if selectedIndex.isEmpty == false {
            let array = indexs.flatMap { num in
                return question?.answerList?[num]
            }
            requestAnwsers(array)
        } else {
            MBProgressHUD.errorMessage(view: view, message: R.string.localizable.alertTitle_please_select_answer())
        }
    }

}

extension AnswerQuestionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension AnswerQuestionViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return question?.answerList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: AnswerQuestionTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.answerQuestionTableViewCell, for: indexPath) else {
            return UITableViewCell()
        }
        if let array = question?.answerList {
            cell.configData(array[indexPath.row])
        }
        return cell
    }
}

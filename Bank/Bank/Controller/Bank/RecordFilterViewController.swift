//
//  RecordFilterViewController.swift
//  Bank
//
//  Created by Koh Ryu on 16/1/20.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import SwiftDate
import Alamofire
import PromiseKit
import URLNavigator
import MBProgressHUD
import PullToRefresh

public enum DataType: Int {
    /// 积分明细
    case point
    /// 银行卡明细
    case bank
    /// 还款明细
    case debt
}

class RecordFilterViewController: BaseViewController {
    
    @IBOutlet weak var calendar2ImageView: UIImageView!
    @IBOutlet weak var calendar1ImageView: UIImageView!
    @IBOutlet fileprivate weak var startTextField: UITextField!
    @IBOutlet fileprivate weak var endTextField: UITextField!
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var pickerView: UIDatePicker!
    
    fileprivate lazy var noneView: NoneView = { return NoneView(frame: self.tableView.bounds, type: .other)}()
    fileprivate var toolBar: InputAccessoryToolbar!
    
    var filterType: DetailActionType?
    var type: BalanceStatementType = .cardBill
    var cardID: String?
    var dataType: DataType = .bank
    
    fileprivate var datas: [TransactionDetail] = []
    fileprivate var startTime: Date?
    fileprivate var endTime: Date?
    fileprivate var pointArray: [PointObject] = []
    fileprivate var repayments: [Repayment] = []
    fileprivate var currentPage: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        startTextField.delegate = self
        endTextField.delegate = self
        pickerView.maximumDate = Date()
        startTextField.setValue(UIColor.white.withAlphaComponent(0.5), forKeyPath: "_placeholderLabel.textColor")
        endTextField.setValue(UIColor.white.withAlphaComponent(0.5), forKeyPath: "_placeholderLabel.textColor")
        setupTableView()
        setupCondition()
        addPullToRefresh()
    }
    
    deinit {
        if let tableView = tableView {
            if let bottomRefresh = tableView.bottomPullToRefresh {
                tableView.removePullToRefresh(bottomRefresh)
            }
        }
    }
    
    fileprivate func addPullToRefresh() {
        let bottomRefresh = PullToRefresh(position: .bottom)
        tableView.addPullToRefresh(bottomRefresh) { [weak self] in
            if self?.dataType == .bank {
                self?.requestRecordData((self?.currentPage ?? 1) + 1)
            } else if self?.dataType == .point {
                self?.requestPointData((self?.currentPage ?? 1) + 1)
            } else {
                self?.requesDebtData((self?.currentPage ?? 1) + 1)
            }
            self?.tableView.endRefreshing(at: .bottom)
        }
    }
    
    func setupTableView() {
        if dataType == .bank {
            tableView.register(R.nib.accountTableViewCell)
        } else if dataType == .point {
            tableView.register(R.nib.integralDetailMenuTableViewCell)
        } else {
            tableView.register(R.nib.detailTableViewCell)
        }
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.configBackgroundView()
    }
    
    func setupCondition() {
        toolBar = R.nib.inputAccessoryToolbar.firstView(owner: self, options: nil)
        toolBar.doneHandleBlock = {
            if self.startTextField.isFirstResponder {
                self.startTextField.text = self.pickerView.date.toString("yyyy-MM-dd")
                self.startTime = self.pickerView.date
            } else if self.endTextField.isFirstResponder {
                self.endTextField.text = self.pickerView.date.toString("yyyy-MM-dd")
                self.endTime = self.pickerView.date
            }
            self.view.endEditing(true)
        }
        toolBar.cancelHandleBlock = {
            self.view.endEditing(true)
        }
        
        startTextField.inputView = pickerView
        startTextField.inputAccessoryView = toolBar
        endTextField.inputView = pickerView
        endTextField.inputAccessoryView = toolBar
        guard let type = filterType else {
            return
        }
        switch type {
        case .filter3Month:
            endTextField.text = Date().toString("yyyy-MM-dd")
            startTextField.text = 3.months.ago()?.toString("yyyy-MM-dd")
            endTime = Date()
            startTime = 3.months.ago()
        case .filterMonth:
            endTextField.text = Date().toString("yyyy-MM-dd")
            startTextField.text = 1.months.ago()?.toString("yyyy-MM-dd")
            endTime = Date()
            startTime = 1.months.ago()
        case .filterWeek:
            endTextField.text = Date().toString("yyyy-MM-dd")
            startTextField.text = 7.days.ago()?.toString("yyyy-MM-dd")
            endTime = Date()
            startTime = 7.days.ago()
        default:
            break
        }
    }

    @IBAction func doneHandle() {
        // TODO: record filter
        if dataType == .bank {
            requestRecordData()
        } else if dataType == .point {
            requestPointData()
        } else {
            requesDebtData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        calendar1ImageView.image = UIImage(named: startTextField.text == "" ? "btn_calendar1" : "btn_calendar2")
        calendar2ImageView.image = UIImage(named: endTextField.text == "" ? "btn_calendar1" : "btn_calendar2")
    }
}

// MARK: - Request
extension RecordFilterViewController {
    /// 请求银行卡明细
    func requestRecordData(_ page: Int = 1) {
        let parameter = BankCardParameter()
        parameter.cardID = cardID
        parameter.startTime = startTime
        parameter.endTime = endTime
        parameter.page = page
        parameter.perPage = 20
        let req: Promise<BankCardTransformDetailListData> = handleRequest(Router.endpoint( BankCardPath.bill, param: parameter))
        req.then { (value) -> Void in
            if let items = value.data?.items {
                self.currentPage = page
                if self.currentPage == 1 {
                    self.datas = items
                } else {
                    self.datas.append(contentsOf: items)
                }
                self.tableView.reloadData()
            }
            if self.datas.isEmpty {
                self.tableView.tableFooterView = self.noneView
            } else {
                self.tableView.tableFooterView = UIView()
            }
            }.catch { error in
                guard let err = error as? AppError else {
                    return
                }
                MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
        }
    }
    
    /// 请求积分明细
    func requestPointData(_ page: Int = 1) {
        MBProgressHUD.loading(view: view)
        validDate(page).then { (param) -> Promise<PointObjectListData> in
            let req: Promise<PointObjectListData> = handleRequest(Router.endpoint( MallPath.pointEarnList, param: param))
            return req
            }.then { value -> Void in
                if value.isValid {
                    if let items = value.data?.items {
                        self.currentPage = page
                        if self.currentPage == 1 {
                            self.pointArray = items
                        } else {
                            self.pointArray.append(contentsOf: items)
                        }
                        self.tableView.reloadData()
                    }
                }
                if self.pointArray.isEmpty {
                    self.tableView.tableFooterView = self.noneView
                } else {
                    self.tableView.tableFooterView = UIView()
                }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    fileprivate func validDate(_ page: Int) -> Promise<MallParameter> {
        return Promise { fulfill, reject in
            let count = startTime != nil && endTime != nil
            switch count {
            case true:
                let param = MallParameter()
                param.page = page
                param.startTime = startTime
                param.endTime = endTime
                fulfill(param)
            case false:
                let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                reject(error)
            }
            
        }
    }
    
    /**
     请求还款明细数据
     */
    func requesDebtData(_ page: Int = 1) {
        MBProgressHUD.loading(view: view)
        let param = MallParameter()
        param.page = page
        param.startTime = startTime
        param.endTime = endTime
        let req: Promise<RepaymentListData> = handleRequest(Router.endpoint( EAccountPath.creditBillHistory, param: param))
        req.then { (value) -> Void in
            if value.isValid {
                if let repayment = value.data?.items {
                    self.currentPage = page
                    if self.currentPage == 1 {
                        self.repayments = repayment
                    } else {
                        self.repayments.append(contentsOf: repayment)
                    }
                }
                self.tableView.reloadData()
            }
            if self.repayments.isEmpty {
                self.tableView.tableFooterView = self.noneView
            } else {
                self.tableView.tableFooterView = UIView()
            }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }

}

// MARK: - UITextFieldDelegate
extension RecordFilterViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == startTextField {
        calendar1ImageView.image = UIImage(named: startTextField.text == "" ? "btn_calendar1" : "btn_calendar2")
        } else {
        calendar2ImageView.image = UIImage(named: endTextField.text == "" ? "btn_calendar1" : "btn_calendar2")
        }
    }
}

// MARK: Table View Data Source
extension RecordFilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataType == .bank {
            return datas.count
        } else if dataType == .point {
            return pointArray.count
        } else {
            return repayments.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if dataType == .bank {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.accountTableViewCell, for: indexPath) else {
                return UITableViewCell()
            }
            cell.configBalanceStatement(datas[indexPath.row])
            return cell
        } else if dataType == .point {
            guard let cell: IntegralDetailMenuTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.integralDetailMenuTableViewCell, for: indexPath) else {
                return UITableViewCell()
            }
            cell.conforInfo(pointArray[indexPath.row])
            return cell
        } else {
            guard  let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.detailTableViewCell, for: indexPath) else {
                return UITableViewCell()
            }
            cell.configInfo(self.repayments[indexPath.row])
            return cell
        }

    }
}

// MARK: - UITableViewDelegate
extension RecordFilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 13.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}

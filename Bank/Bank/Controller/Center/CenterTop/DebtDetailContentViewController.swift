//
//  DebtDetailContentViewController.swift
//  Bank
//
//  Created by Koh Ryu on 11/30/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//  
//  swiftlint:disable private_outlet

import UIKit
import PromiseKit
import URLNavigator
import PullToRefresh
import MBProgressHUD

class DebtDetailContentViewController: BaseViewController {
    
    fileprivate let datePickView = UIDatePicker()

    @IBOutlet fileprivate weak var tableView: UITableView!

    @IBOutlet fileprivate weak var  headerView: UIView!
    
    @IBOutlet weak var beginTimeTextField: UITextField!
    @IBOutlet weak var endTimeTextField: UITextField!
    fileprivate var page = 1

    var repayments: [Repayment] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDatePicker()
        addPullToRefresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestData()
    }
    
    deinit {
        if let tableView = tableView {
            if let topRefresh = tableView.topPullToRefresh {
                tableView.removePullToRefresh(topRefresh)
            }
            if let bottomRefresh = tableView.bottomPullToRefresh {
                tableView.removePullToRefresh(bottomRefresh)
            }
        }
    }
    
    fileprivate func addPullToRefresh() {
        let topRefresh = TopPullToRefresh()
        let bottomRefresh = PullToRefresh(position: .bottom)
        tableView.addPullToRefresh(bottomRefresh) { [weak self] in
            self?.requestData((self?.page ?? 1) + 1)
            self?.tableView.endRefreshing(at: .bottom)
        }
        tableView.addPullToRefresh(topRefresh) { [weak self] in
            self?.requestData()
        }
    }
    
    @IBAction func defineHandle(_ sender: UIButton) {
        requestData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

extension DebtDetailContentViewController {
    
    func setupUI() {
        title = R.string.localizable.controller_title_repayment_details()
        tableView.register(R.nib.detailTableViewCell)
        tableView.tableFooterView = UIView()
        tableView.configBackgroundView()
        headerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100)
        tableView.tableHeaderView = headerView
    }
    
    /**
     请求还款明细数据
     */
    func requestData(_ page: Int = 1) {
        MBProgressHUD.loading(view: view)

        let param = MallParameter()
        param.page = page

        if let starTime = self.beginTimeTextField.text {
            param.sTime = starTime
        }
        if let endTime = self.endTimeTextField.text {
            param.eTime = endTime
        }
        let req: Promise<RepaymentListData> = handleRequest(Router.endpoint(EAccountPath.creditBillHistory, param: param))
        req.then { (value) -> Void in
            if value.isValid {
                if let repayment = value.data?.items {
                    self.page = page
                    if self.page == 1 {
                        self.repayments = repayment
                    } else {
                        self.repayments.append(contentsOf: repayment)
                    }
                }
                self.tableView.reloadData()
            }
            }.always {
                self.tableView.endRefreshing(at: .top)
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let refresh = tableView.topPullToRefresh {
            tableView.removePullToRefresh(refresh)
        }
        if let refresh = tableView.bottomPullToRefresh {
            tableView.removePullToRefresh(refresh)
        }
    }
}

extension DebtDetailContentViewController {
    
     func setupDatePicker() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        let denifineBarButtonItem = UIBarButtonItem(title: R.string.localizable.alertTitle_confirm(), style: .plain, target: self, action: #selector(self.denifine))
        let cancleBarButtonItem = UIBarButtonItem(title: R.string.localizable.alertTitle_cancel(), style: .plain, target: self, action: #selector(self.cancle))
        let spaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        toolbar.items = [denifineBarButtonItem, spaceBarButtonItem, cancleBarButtonItem]
        endTimeTextField.inputAccessoryView = toolbar
        beginTimeTextField.inputAccessoryView = toolbar
        datePickView.datePickerMode = .date
        datePickView.locale = Locale(identifier: "zh")
        datePickView.addTarget(self, action: #selector(self.changeTime(_:)), for: .valueChanged)
        endTimeTextField.inputView = datePickView
        beginTimeTextField.inputView = datePickView
    }
    func denifine() {
        changeTime(self.datePickView)
    }
    func cancle() {
        self.view.endEditing(true)
    }
    func changeTime(_ datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: datePicker.date)
        if beginTimeTextField.isEditing {
            beginTimeTextField.text = dateString
        } else {
            endTimeTextField.text = dateString
        }
    }
    
    func dateFromString(_ timeString: String) -> Date? {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let date = fmt.date(from: timeString)
        return date
    }
}

// MARK: Table View Data Source
extension DebtDetailContentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.repayments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard  let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.detailTableViewCell, for: indexPath) else {
           return UITableViewCell()
        }
        cell.configInfo(self.repayments[indexPath.row])
        return cell
    }
}

// MARK: Table View Delegate
extension DebtDetailContentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 17
    }
}

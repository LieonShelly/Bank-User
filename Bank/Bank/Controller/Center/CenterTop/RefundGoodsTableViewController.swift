//
//  RefundGoodsTableViewController.swift
//  Bank
//
//  Created by yang on 16/5/13.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import ImagePicker
import MBProgressHUD

class RefundGoodsTableViewController: BaseTableViewController {
    
    @IBOutlet fileprivate weak var refundTypeLabel: UILabel!
    @IBOutlet fileprivate weak var refundReasonLabel: UILabel!
    @IBOutlet fileprivate weak var desTextView: UITextView!
    @IBOutlet fileprivate weak var placeLabel: UILabel!
    @IBOutlet fileprivate var footerView: UIView!
    @IBOutlet fileprivate weak var refundPriceTextField: UITextField!
    @IBOutlet fileprivate weak var addButton: UIButton!
    @IBOutlet fileprivate var imageViews: [UIImageView]!
    @IBOutlet fileprivate var deleteButtons: [UIButton]!
    @IBOutlet fileprivate weak var textCountLabel: UILabel!
    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    
    var order: Order?
    
    fileprivate var param: OrderParameter = OrderParameter()
    fileprivate var imageArray: [UIImage] = []
    fileprivate var imagePicker: ImagePickerController!
    fileprivate var reasonArray: [NormalRefundReason] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        desTextView.delegate = self
        desTextView.returnKeyType = .done
        refundPriceTextField.addTarget(self, action: #selector(self.alertTextFieldChange(textFiled:)), for: .editingChanged)
        refundPriceTextField.keyboardType = .decimalPad
        if let reasons = AppConfig.shared.baseData?.normalRefundReasons {
            reasonArray = reasons
        }
        setTableView()
        setTextView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        stackViewHeight.constant = addButton.frame.width
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PickerViewController {
            let array = self.reasonArray.map { return $0.reasonName }
            vc.dataSource = array
            vc.didSelect = { index in
                if index != -1 && self.reasonArray.count > index {
                    self.refundReasonLabel.text = array[index]
                }
            }
        }
        if let vc = segue.destination as? RefundDetailTableViewController {
            vc.refundID = self.order?.refundID
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setTableView() {
        tableView.configBackgroundView()
        tableView.tableFooterView = footerView
        tableView.isUserInteractionEnabled = true
    }
    
    func setTextView() {
        textView.delegate = self
        if let tel = AppConfig.shared.baseData?.serviceHotLine {
            textView.text = "为确保顺利退款，建议您在提交退款申请前，先与商家电话沟通达成一致，并获取退货地址。如遇困难，您可拨打平台客服电话：\(tel)获取帮助。更多疑问请查看帮助中心。"
        }
        textView.linkTextAttributes = [NSUnderlineStyleAttributeName: 1, NSForegroundColorAttributeName: UIColor(hex: 0x00a8fe)]
    }
    
    @IBAction func submitAction(_ sender: UIButton) {
        requestSubmitRefundData()
    }
    
    //添加图片
    @IBAction func addImageViewAction(_ sender: UIButton) {
        if imageArray.count >= 4 {
            Navigator.showAlertWithoutAction(nil, message: "最多选择4张")
            return
        }
        imagePicker = nil
        var configuration = Configuration()
        configuration.doneButtonTitle = R.string.localizable.image_picker_button_done()
        configuration.noImagesTitle = R.string.localizable.image_picker_button_no_available_photo()
        configuration.cancelButtonTitle = R.string.localizable.image_picker_button_cancel()
        configuration.recordLocation = false
        imagePicker = ImagePickerController(configuration: configuration)
        imagePicker.imageLimit = 4 - imageArray.count
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func deleteHandle(_ sender: UIButton) {
        imageArray.remove(at: sender.tag)
        for view in imageViews {
            view.image = nil
        }
        for button in deleteButtons {
            button.isHidden = true
        }
        layoutImageViews(imageArray, isDelete: true)
    }
    
    func layoutImageViews(_ images: [UIImage], isDelete: Bool = false) {
        for index in 0..<images.count {
            let offsetIndex = isDelete ? 0 : imageArray.count
            let imageView = imageViews[index + offsetIndex]
            imageView.image = images[index]
            let button = deleteButtons[index + offsetIndex]
            button.isHidden = false
        }
    }
    
    @IBAction func unwindRefundGoodsFromPicker(_ segue: UIStoryboardSegue) {
        dim(.out, coverNavigationBar: true)
    }
    
    func showReasonPickerView() {
        dim(.in, coverNavigationBar: true)
        performSegue(withIdentifier: R.segue.refundGoodsTableViewController.showPickerView, sender: nil)
    }
}

// MARK: Request
extension RefundGoodsTableViewController {
    /**
     提交申请
     */
    func requestSubmitRefundData() {
        MBProgressHUD.loading(view: view)
        validInputs().then { () -> Promise<FileUploadResponse> in
            return self.requestSendPhotos()
            }.then { (value) -> Promise<ApplyRefundData> in
                var imageURLs: [URL] = []
                if let successList = value.data?.successList {
                    for fileObject in successList {
                        if let url = fileObject.url {
                            imageURLs.append(url)
                        }
                    }
                }
                self.param.imageURLs = imageURLs
                let req: Promise<ApplyRefundData> = handleRequest(Router.endpoint( OrderPath.order(.refund), param: self.param))
                return req
            }.then { (value) -> Void in
                if let order = value.data {
                    self.order?.refundID = order.refundID
                }
                self.performSegue(withIdentifier: R.segue.refundGoodsTableViewController.showRefundDetailVC, sender: nil)
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
        
    }
    
    fileprivate func requestSendPhotos() -> Promise<FileUploadResponse> {
        var imageData: [Data] = []
        for image in imageArray {
            if let data = UIImageJPEGRepresentation(image, 0.5) {
                imageData.append(data)
            }
        }
        let param = FileUploadParameter()
        param.dir = .orderRefund
        
        let req: Promise<FileUploadResponse> = handleUpload(Router.upload(endpoint: FileUploadPath.upload), param: param, fileData: imageData)
        
        return req
    }
    
    fileprivate func validInputs() -> Promise<Void> {
        return Promise { fulfill, reject in
            guard let refundPrice = refundPriceTextField.text else {
                let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                return reject(error)
            }
            let count = !refundPrice.characters.isEmpty
            switch count {
            case true:
                self.param.orderID = order?.orderID
                self.param.refundType = nil
                self.param.refundAmount = Float(refundPrice)
                self.param.reason = refundReasonLabel.text
                self.param.remark = desTextView.text
                fulfill()
            case false:
                let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                reject(error)
            }
            
        }
    }
}

// MARK: UITableViewDataSource
extension RefundGoodsTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
}

// MARK: UITableViewDelegate
extension RefundGoodsTableViewController {
    
//    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//        if section == 0 {
//            if let price = order?.totalPrice, let deliveryCost = order?.deliveryCost {
//                return "退款金额说明：商品价格\(price)元 + 快递 \(deliveryCost)元"
//            }
//        }
//        return nil
//    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 1 {
            return 115
        }
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            view.endEditing(true)
            showReasonPickerView()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 45
        }
        return 5
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 20
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let view = UIView()
            let label = UILabel()
            label.textColor = UIColor(hex: 0x666666)
            label.font = UIFont.systemFont(ofSize: 14)
            label.numberOfLines = 2
            if let price = order?.totalPrice.numberToString(), let deliveryCost = order?.deliveryCost.numberToString() {
                label.text = "退款金额说明：商品价格\(price)元 + 快递 \(deliveryCost)元"
            }
            view.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.top.equalTo(view).offset(2)
                make.left.equalTo(view).offset(17)
                make.right.equalTo(view).offset(-13)
                make.bottom.equalTo(view).offset(-5)
            }
            return view
        }
        return nil
    }
    
}

// MARK: - Image Picker Delegate
extension RefundGoodsTableViewController: ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismiss(animated: true) {
            self.layoutImageViews(images)
            self.imageArray.append(contentsOf: images)
        }
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextViewDelegate
extension RefundGoodsTableViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let count = textView.text.characters.count
        if textView.text.characters.isEmpty {
            placeLabel.text = "请补充退款说明"
        } else {
            placeLabel.text = ""
        }
        textCountLabel.text = "\(count)/100"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.characters.isEmpty {
            return true
        }
        if text == "\n" {
            view.endEditing(true)
        }
        if textView.text?.characters.count > 99 {
            return false
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        let tel = NSString(string: textView.text).substring(with: characterRange)
        setTelAlertViewController(tel)
        return false
    }
    
}

// UITextFieldDelegate
extension RefundGoodsTableViewController {
    func alertTextFieldChange(textFiled: UITextField) {
        guard let priceText = textFiled.text else {return}
        let price = Float(priceText)
        if price > order?.totalPrice {
            Navigator.showAlertWithoutAction(nil, message: "不能超出付款金额总数")
            textFiled.text = (priceText as NSString).substring(to: priceText.characters.count-1)
            return
        }
        textFiled.text = priceText.keepTwoPlacesDecimal()
    }
}

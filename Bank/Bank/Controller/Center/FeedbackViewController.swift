//
//  FeedbackViewController.swift
//  Bank
//
//  Created by Mac on 15/11/24.
//  Copyright © 2015年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import ImagePicker
import Kingfisher
import MBProgressHUD

class FeedbackViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var catLabel: UILabel!
    @IBOutlet fileprivate weak var reasonLabel: UILabel!
    @IBOutlet fileprivate weak var placeholderLabel: UILabel!
    @IBOutlet fileprivate weak var textView: UITextView!
    @IBOutlet fileprivate weak var textField: UITextField!
    @IBOutlet fileprivate weak var stackViewHeight: NSLayoutConstraint!
    @IBOutlet fileprivate weak var addButton: UIButton!
    @IBOutlet fileprivate var imageViews: [UIImageView]!
    @IBOutlet fileprivate var deleteButtons: [UIButton]!
    @IBOutlet fileprivate weak var textCountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    
    fileprivate var catArray: [FeedbackCat] = []
    fileprivate var reasonArray: [FeedbackCat] = []
    fileprivate var imagePicker: ImagePickerController!
    fileprivate var imageArray: [UIImage] = []
    fileprivate var param: UserParameter = UserParameter()
    fileprivate var showCatPicker: Bool = false
    
    // MARK: - override function
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.configBackgroundView()
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        requestFeedbackListData()
        textView.delegate = self
        param.platfrom = .member
        let touch = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(touch)
        addButton.imageView?.contentMode = .scaleAspectFill
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        stackViewHeight.constant = addButton.frame.width
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.segue.feedbackViewController.showPickerView.identifier {
            guard let vc = segue.destination as? PickerViewController else { return }
            if showCatPicker {
                let array = self.catArray.map { return $0.catName }
                vc.dataSource = array
                vc.didSelect = { index in
                    if index != -1 && self.catArray.count > index {
                        let feedbackCat = self.catArray[index]
                        self.param.feedbackCatID = feedbackCat.catID
                        self.catLabel.text = self.catArray[index].catName
                        self.reasonArray = feedbackCat.subCats
                        if !feedbackCat.subCats.isEmpty {
                            self.param.feedbackReasonID = self.reasonArray[0].catID
                            self.reasonLabel.text = self.reasonArray[0].catName
                        }
                    }
                }
            } else {
                let array = self.reasonArray.map { return $0.catName }
                vc.dataSource = array
                vc.didSelect = { index in
                    if index != -1 && self.reasonArray.count > index {
                        self.param.feedbackReasonID = self.reasonArray[index].catID
                        self.reasonLabel.text = self.reasonArray[index].catName
                    }
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // MARK: - fileprivate function
    
    @objc fileprivate func keyboardWillShow(_ notific: Foundation.Notification) {
        guard let dic = notific.userInfo as? [String: Any], let keyboardFrame = dic["UIKeyboardBoundsUserInfoKey"] as? CGRect else {
            return
        }
        print(keyboardFrame)
        UIView.animate(withDuration: 0.25, animations: {
            self.tableView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.view.frame.size.width, height: self.tableView.frame.height - keyboardFrame.height))
        })
    }
    
    @objc fileprivate func keyboardWillHidden(_ notific: Foundation.Notification) {
        UIView.animate(withDuration: 0.25, animations: {
            self.tableView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.view.frame.size)
        })
    }

    @objc fileprivate func dismissKeyboard() {
        view.endEditing(true)
    }
    
    fileprivate func layoutImageViews(_ images: [UIImage], isDelete: Bool = false) {
        for index in 0..<images.count {
            let offsetIndex = isDelete ? 0 : imageArray.count
            let imageView = imageViews[index + offsetIndex]
            imageView.image = images[index]
            let button = deleteButtons[index + offsetIndex]
            button.isHidden = false
        }
    }
    
    // MARK: - IBAction function
    
    //添加图片
    @IBAction func addImageViewAction(_ sender: UIButton) {
        if imageArray.count >= 4 {
            let alert = UIAlertController(title: nil, message: R.string.localizable.alertTitle_max_add_image(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_okay(), style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
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
    
    @IBAction func unwindFeedbackFromPicker(_ segue: UIStoryboardSegue) {
        dim(.out, coverNavigationBar: true)
    }
    
    @IBAction func showCatPickerView() {
        dim(.in, coverNavigationBar: true)
        showCatPicker = true
        performSegue(withIdentifier: R.segue.feedbackViewController.showPickerView, sender: nil)
    }
    
    @IBAction func showReasonPickerView() {
        dim(.in, coverNavigationBar: true)
        showCatPicker = false
        performSegue(withIdentifier: R.segue.feedbackViewController.showPickerView, sender: nil)
    }
    
    @IBAction func submitAction(_ sender: UIButton) {
        validInputs().then { () -> Promise<FileUploadResponse> in
            return self.requestSendPhotos()
        }.then { (value) -> Promise<NullDataResponse> in
            var imageURLs: [URL] = []
            if let successList = value.data?.successList {
                for fileObject in successList {
                    if let url = fileObject.url {
                        imageURLs.append(url)
                    }
                }
            }
            self.param.feedbackImages = imageURLs
            let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( UserPath.feedback, param: self.param))
            return req
        }.then { (value) -> Void in
            // success
            _ = self.navigationController?.popViewController(animated: true)
        }.always { 
            MBProgressHUD.hide(for: self.view, animated: true)
        }.catch { (error) in
            if let err = error as? AppError {
                MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
            }
        }
    }
    
}

// MARK: - Request
extension FeedbackViewController {
    /**
     请求反馈分类
     */
    fileprivate func requestFeedbackListData() {
        MBProgressHUD.loading(view: view)
        let req: Promise<FeedbackCatListData> = handleRequest(Router.endpoint( FeedbackPath.catList, param: nil))
        req.then { (value) -> Void in
            if let items = value.data?.catList {
                self.catArray = items
            }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    /// 上传图片
    fileprivate func requestSendPhotos() -> Promise<FileUploadResponse> {
        var imageData: [Data] = []
        for image in imageArray {
            if let data = UIImageJPEGRepresentation(image, 0.5) {
                imageData.append(data)
            }
        }
        MBProgressHUD.loading(view: view)
        let param = FileUploadParameter()
        param.dir = .feedback
        
        let req: Promise<FileUploadResponse> = handleUpload(Router.upload(endpoint: FileUploadPath.upload), param: param, fileData: imageData)
        
        return req
    }
    
    /// 校验信息
    fileprivate func validInputs() -> Promise<Void> {
        return Promise { fulfill, reject in
            if let content = textView.text, let contact = textField.text, let _ = param.feedbackCatID, let _ = param.feedbackReasonID {
                param.feedbackContent = content
                param.feedbackContact = contact
                fulfill()
            } else {
                let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                reject(error)
            }
        }
    }
}

// MARK: - Image Picker Delegate
extension FeedbackViewController: ImagePickerDelegate {
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

// MARK: - UITextFieldDelegate
extension FeedbackViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let count = textView.text.characters.count
        if textView.text.characters.isEmpty {
            placeholderLabel.text = R.string.localizable.placeHoder_title_refund_explain()
        } else {
            placeholderLabel.text = ""
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
    
}

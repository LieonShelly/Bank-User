//
//  PersonalDataTableViewController.swift
//  Bank
//
//  Created by Mac on 15/11/25.
//  Copyright © 2015年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import PromiseKit
import URLNavigator
import Kingfisher
import Proposer
import MBProgressHUD

class ProfileViewController: BaseTableViewController {
    
    @IBOutlet fileprivate weak var headImageView: UIImageView!
    @IBOutlet fileprivate weak var nicknameLabel: UILabel!
    
    @IBOutlet fileprivate weak var desc1Label: UILabel!
    @IBOutlet fileprivate weak var desc2Label: UILabel!
    @IBOutlet fileprivate weak var value1Label: UILabel!
    @IBOutlet fileprivate weak var value2Label: UILabel!
    
    fileprivate var actionSheet: UIAlertController!
    fileprivate lazy var imagePickerVC: UIImagePickerController = UIImagePickerController()
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.configBackgroundView()
        imagePickerVC.allowsEditing = true
        imagePickerVC.delegate = self
        requestUserData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
   
    fileprivate func setAccountInfo(_ user: User?) {
        guard let user = user else {
            return
        }
        nicknameLabel.text = user.nickname
        if let url = user.imageURL {
            headImageView.setImage(with: url,
                                   placeholderImage: R.image.head_default())
        } else {
            headImageView.image = R.image.head_default()
        }
        
        if let phoneString = user.mobile {
            desc2Label.text = "手机号"
            value2Label.text = phoneString.replaceWith(range: NSRange(location: 3, length: 4))
        }
        desc1Label.text = "姓名"
        value1Label.text = user.name
        
    }
    
    fileprivate func requestInfoEdit(_ param: UserParameter) -> Promise<NullDataResponse> {
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint(UserPath.update, param: param))
        return req
    }
    
    fileprivate func requestCameraPermission() {
        let cameraPermission: PrivateResource = .camera
        
        proposeToAccess(cameraPermission, agreed: { [weak self] _ in
            self?.requestPhotosPermission()
            }, rejected: { [weak self] _ in
                let alert = UIAlertController(title: nil, message: R.string.localizable.alertTitle_permission_camera(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_setting(), style: .default, handler: { (action) in
                    if let url = URL(string: UIApplicationOpenSettingsURLString) {
                        Navigator.openInnerURL(url)
                    }
                }))
                alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: .cancel, handler: { (action) in
                    _ = self?.navigationController?.popViewController(animated: true)
                }))
                self?.present(alert, animated: true, completion: nil)
        })
        
    }
    
    fileprivate func requestPhotosPermission() {
        
        let photoPermission: PrivateResource = .photos
        
        proposeToAccess(photoPermission, agreed: { [weak self] _ in
            self?.editAvatar()
            }, rejected: { [weak self] _ in
                let alert = UIAlertController(title: nil, message: R.string.localizable.alertTitle_permission_photos(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_setting(), style: .default, handler: { (action) in
                    if let url = URL(string: UIApplicationOpenSettingsURLString) {
                        Navigator.openInnerURL(url)
                    }
                }))
                alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: .cancel, handler: { (action) in
                    _ = self?.navigationController?.popViewController(animated: true)
                }))
                self?.present(alert, animated: true, completion: nil)
        })
    }
    
    fileprivate func editAvatar() {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "拍照", style: .default) { (action) in
            self.imagePickerVC.sourceType = .camera
            self.present(self.imagePickerVC, animated: true, completion: nil)
        }
        let photo = UIAlertAction(title: "从相册选择", style: .default) { (action) in
            self.imagePickerVC.sourceType = .photoLibrary
            self.present(self.imagePickerVC, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: .cancel, handler: nil)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(camera)
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(photo)
        }
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.segue.profileViewController.showEditNameVC.identifier {
            if let vc = segue.destination as? UpdateNameViewController {
                vc.userName = user?.nickname
                vc.needUpdateData = { [weak self] name in
                    if let name = name, !name.isEmpty {
                        self?.user?.nickname = name
                        self?.setAccountInfo(self?.user)
                    }
                }
            }
        }
    }
    
    fileprivate func requestUpload(_ image: UIImage) {
        self.headImageView.image = image
        guard let imageData: Data = UIImageJPEGRepresentation(image, 0.5) else { return }
        
        MBProgressHUD.loading(view: self.view)
        let param = FileUploadParameter()
        param.dir = .userAvatar
        let req = handleUpload(Router.upload(endpoint: FileUploadPath.upload), param: param, fileData: [imageData])
            req.then { (value) -> Promise<NullDataResponse> in
                if let list = value.data?.successList, !list.isEmpty, let url = list[0].url?.absoluteString {
                    let param = UserParameter()
                    param.avatar = url
                    return handleRequest(Router.endpoint(UserPath.update, param: param))
                } else {
                    let err = AppError(code: RequestErrorCode.unknown, msg: "上传失败")
                    throw err
                }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }

    func requestUserData() {
        MBProgressHUD.loading(view: view)
        let req: Promise<GetUserInfoData> = handleRequest(Router.endpoint(UserPath.profile, param: nil))
        req.then { (value) -> Void in
            self.user = value.data
            self.setAccountInfo(value.data)
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { error in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }

}

extension ProfileViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        dismiss(animated: true) { 
            self.requestUpload(image)
        }
    }
}

extension ProfileViewController: UINavigationControllerDelegate {
    
}

extension ProfileViewController {

}

// MARK: - Table View Delegate
extension ProfileViewController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 17 : 9
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.row, indexPath.section) {
        
        case (0, 0):
            requestCameraPermission()
        case (1, 0):
            performSegue(withIdentifier: R.segue.profileViewController.showEditNameVC, sender: nil)
        case(2, 1):
            guard let vc = R.storyboard.center.clerkDetailsViewController() else {return}
            self.navigationController?.pushViewController(vc, animated: true)
            vc.isSourceHome = false
            vc.block = {
                self.user?.isStaff = false
                self.tableView.reloadData()
            }
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let (section, row) = (indexPath.section, indexPath.row)
        switch (section, row) {
        case(0, 0):
            return 100
        case(0, 1):
            return 50
        case(1, 0):
            return self.user?.isSigned == true ? 50 : 0
        case(1, 1):
            return 50
        case(1, 2):
            return self.user?.isStaff == true ? 50 : 0
        default:
            return 50
        }
    }
}

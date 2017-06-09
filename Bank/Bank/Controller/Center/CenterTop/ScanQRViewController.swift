//
//  ScanQRViewController.swift
//  Bank
//
//  Created by 杨锐 on 2016/10/17.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import AVFoundation
import PromiseKit
import URLNavigator
import Proposer
import MBProgressHUD

let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height
let scanWidth = screenWidth - 100
let scanHeight = scanWidth

class ScanQRViewController: BaseViewController {

    fileprivate var session: AVCaptureSession?
    fileprivate var previewLayer: AVCaptureVideoPreviewLayer?
    fileprivate lazy var imageView: UIImageView = UIImageView()
    
    fileprivate var code: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = UIColor.black
        self.setupUI()
        requesPermission()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    @objc private func backAction() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    private func requesPermission() {
        let camera: PrivateResource = .camera
        
        proposeToAccess(camera, agreed: { [weak self] _ in
            self?.startScan()
        }, rejected: { [weak self] _ in
            //self?.stopScan()
            let alert = UIAlertController(title: nil, message: R.string.localizable.alertTitle_permission_camera(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_okay(), style: .cancel, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        })
    }
    
    fileprivate func setupUI() {
        
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        // 创建会话
        session = AVCaptureSession()
        var input: AVCaptureDeviceInput?
        do {
            input = try AVCaptureDeviceInput(device: device)
            if let deviceInput = input {
                session?.addInput(deviceInput)
            }
            let output = AVCaptureMetadataOutput()
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            // 设置扫描区域
            output.rectOfInterest = CGRect(x: 0.25, y: 50/screenWidth, width: scanHeight/screenHeight, height: scanWidth/screenWidth)
            session?.addOutput(output)
            // 设置元数据类型
            output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            
            // 创建输出对象
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            previewLayer?.frame = view.bounds
            if let layer = previewLayer {
                view.layer.addSublayer(layer)
            }
            
        } catch {
            debugPrint("error")
        }
        
        imageView.frame = CGRect(x: 50, y: self.view.bounds.height * 0.25, width: scanWidth, height: scanHeight)
        imageView.image = R.image.qrcode()
        view.addSubview(imageView)
        scanAnimation()
            
        let drawView = ScanQRDrawView(frame: view.bounds)
        drawView.backgroundColor = UIColor.black
        drawView.alpha = 0.5
        view.addSubview(drawView)
            
        let titleLabel = UILabel(frame: CGRect(x: (screenWidth-80)/2, y: 30, width: 80, height: 30))
        titleLabel.text = R.string.localizable.scan_qr_title()
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 21)
        titleLabel.textAlignment = .center
        drawView.addSubview(titleLabel)
            
        let button = UIButton(type: .custom)
        button.setImage(R.image.btn_left_arrow(), for: .normal)
        button.frame = CGRect(x: 10, y: 30, width: 50, height: 30)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        drawView.addSubview(button)
            
        let infoLabel = UILabel(frame: CGRect(x: (screenWidth - 300)/2, y: view.bounds.height * 0.18, width: 300, height: 30))
        infoLabel.textColor = UIColor.white
        infoLabel.text = R.string.localizable.scan_qr_tips()
        infoLabel.font = UIFont.systemFont(ofSize: 17)
        infoLabel.textAlignment = .center
        drawView.addSubview(infoLabel)
        
        // 选定一块区域，设置不同的透明度
        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        let path2 = UIBezierPath(roundedRect: CGRect(x: CGFloat(50), y: view.layer.bounds.height * 0.25, width: scanWidth, height: scanHeight), cornerRadius: 0)
        path.append(path2.reversing())
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        drawView.layer.mask = shapeLayer
    }
    
    /// 开始扫描
    @objc fileprivate func startScan() {
        imageView.isHidden = false
        session?.startRunning()
    }
    
    /// 停止扫描
    fileprivate func stopScan() {
        imageView.isHidden = true
        session?.stopRunning()
    }
    
    /// 动画
    @objc private func scanAnimation() {
        let rect = CGRect(x: 50, y: view.bounds.height * 0.25 - scanHeight, width: scanWidth, height: scanHeight)
        imageView.frame = rect
        imageView.alpha = 0
        
        UIView.animate(withDuration: 1.5, delay: 0.0, options: UIViewAnimationOptions.repeat, animations: {
            self.imageView.alpha = 1
            self.imageView.frame = CGRect(x: 50, y: (self.view.bounds.height) * 0.25, width: scanWidth, height: scanHeight)
            }) { (finished) in
                
        }
    }
    
}

// MARK: - Request
extension ScanQRViewController {
    
    /// 请求优惠买单账单数据
    func requestDiscountData() {
        MBProgressHUD.loading(view: view)
        let param = DiscountParameter()
        param.code = code
        param.scanType = 1
        let req: Promise<DiscountData> = handleRequest(Router.endpoint( DiscountPath.scan, param: param))
        req.then { (value) -> Void in
            guard let vc = R.storyboard.discount.discountBillTableViewController() else { return }
            vc.discount = value.data
            self.navigationController?.pushViewController(vc, animated: true)
            if let count = self.navigationController?.viewControllers.count {
                self.navigationController?.viewControllers.remove(at: count - 2)
            }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
                self.perform(#selector(self.startScan), with: nil, afterDelay: 2.5)
        }

    }
    
    /// 请求打赏数据
    func requestAwardData() {
        MBProgressHUD.loading(view: view)
        let param = AwardParameter()
        param.code = code
        let req: Promise<AwardData> = handleRequest(Router.endpoint( AwardPath.accept, param: param))
        req.then { (value) -> Void in
            if let point = value.data?.point {
                let alert = UIAlertController(title: R.string.localizable.scan_qr_tips_success(point), message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_okay(), style: .default, handler: { [weak self] (action) in
                    self?.startScan()
                    }))
                self.present(alert, animated: true, completion: nil)
            }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
                self.perform(#selector(self.startScan), with: nil, afterDelay: 2.5)
        }
        
    }

}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension ScanQRViewController: AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        stopScan()
        if !metadataObjects.isEmpty {
            guard let obj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject else {
                return
            }
            code = obj.stringValue
            // 打赏二维码 == "4", 优惠买单二维码 == “3”
            if code?.characters.first == "4" {
                requestAwardData()
            } else if code?.characters.first == "3" {
                requestDiscountData()
            } else {
                let alert = UIAlertController(title: nil, message: R.string.localizable.scan_qr_unknown(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_okay(), style: .default, handler: { [weak self] (action) in
                    self?.startScan()
                }))
                present(alert, animated: true, completion: nil)
            }
            
        }
    }
}

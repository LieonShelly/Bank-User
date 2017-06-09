//
//  BranchMapViewController.swift
//  Bank
//
//  Created by Koh Ryu on 16/6/15.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import MapKit
import Proposer
import PromiseKit
import URLNavigator
import Device
import MBProgressHUD

class BranchAnnotation: NSObject, MKAnnotation {
    var branch: Branch
    var coordinate: CLLocationCoordinate2D
    
    init?(branch: Branch) {
        if let coor = branch.coordinate {
            self.coordinate = coor
            self.branch = branch
            super.init()
            
        } else {
            return nil
        }
    }
}

class BranchAnnotationView: MKAnnotationView {
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            image = R.image.coordinate_on_01()
        } else {
            image = R.image.coordinate_on_02()
        }
    }
}

class BranchMapViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var mapView: MKMapView!
    
    fileprivate lazy var branchDetailCell: BankBranchTableViewCell? = {
        let cell = R.nib.bankBranchTableViewCell().instantiate(withOwner: nil, options: nil).first as? BankBranchTableViewCell
        cell?.controller = self
        cell?.frame = CGRect(x: 0, y: self.view.frame.height - 120 - 64 - 10, width: self.view.frame.width, height: 120)
        return cell
    }()
    
    fileprivate var datas: [Branch] = []
    fileprivate var isLoaded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let location: PrivateResource = .location(.whenInUse)
        proposeToAccess(location, agreed: {
            self.mapView.showsUserLocation = true
            }, rejected: {
        })
        let touch = UITapGestureRecognizer(target: self, action: #selector(self.dismissDetail))
        mapView.addGestureRecognizer(touch)
    }
    
    func loadDatas(_ items: [Branch]) {
        datas = items
        var array: [BranchAnnotation] = []
        for i in 0..<datas.count {
            guard let branch = BranchAnnotation(branch: datas[i]) else { continue }
            array.append(branch)
        }
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(array)
    }
    
    fileprivate func requestDatas(_ page: Int = 1, location: CLLocationCoordinate2D) {
        let param = AppointParameter()
        param.page = page
        param.location = location
        let req: Promise<BranchListData> = handleRequest(Router.endpoint(endpoint: AppointPath.bankBranch, param: param))
        req.then { (value) -> Void in
            if let items = value.data?.items, !items.isEmpty {
                self.loadDatas(items)
            }
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    @objc fileprivate func dismissDetail() {
        branchDetailCell?.removeFromSuperview()
    }
    
    fileprivate func showBranchDetail(_ show: Bool) {
        guard let cell = branchDetailCell else { return }
        view.addSubview(cell)
    }
}

extension BranchMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if !isLoaded {
            requestDatas(location: mapView.userLocation.coordinate)
            isLoaded = true
        }
        let mapRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        mapView.setRegion(mapRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isEqual(mapView.userLocation) {
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "userLocation")
            annotationView.image = R.image.coordinate_me()
            return annotationView
        } else if annotation.isKind(of: BranchAnnotation.self) {
            let annotationView = BranchAnnotationView(annotation: annotation, reuseIdentifier: "location")
            annotationView.image = R.image.coordinate_on_02()
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        for annotation in mapView.selectedAnnotations {
            if let view = mapView.view(for: annotation) {
                view.setSelected(false, animated: false)
            }
        }
        view.setSelected(true, animated: true)
        showBranchDetail(true)
        guard let annotation = view.annotation as? BranchAnnotation else { return }
        branchDetailCell?.configData(annotation.branch)
    }
}

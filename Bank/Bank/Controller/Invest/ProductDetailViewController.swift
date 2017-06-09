//
//  ProductDetailViewController.swift
//  Bank
//
//  Created by Koh Ryu on 12/1/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit
import URLNavigator

class ProductDetailViewController: BaseViewController {
    
    @IBOutlet private weak var webView: UIWebView!
    
    var productID: String?
    private var product: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.hidden = true
        requestData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
    }
    
    // MARK: Methods
    private func requestData() {
        let param = InvestProductParameter()
        param.productID = productID

        let req: Promise<InvestProductDetailData> = handleRequest(Router.Endpoint(endpoint: InvestProductPath.ProductDetail, param: param))
        req.then { (value) -> Void in
            guard let data = value.data else { return }
            self.product = data
            if let html = data.html {
                self.webView.loadHTMLString(html, baseURL: nil)
            }
        }
    }
}

extension ProductDetailViewController: UIWebViewDelegate {
    func webViewDidStartLoad(webView: UIWebView) {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        MBProgressHUD.hideHUDForView(view, animated: true)
    }
}

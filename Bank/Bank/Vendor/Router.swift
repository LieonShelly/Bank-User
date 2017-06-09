//
//  Router.swift
//  Bank
//
//  Created by Koh Ryu on 16/3/10.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

// swiftlint:disable identifier_name
// swiftlint:disable force_unwrapping

import Foundation
import Alamofire
import ObjectMapper
import UIKit
import CoreLocation

enum Router: URLRequestConvertible {

    var method: Alamofire.HTTPMethod {
        switch self {
        default:
            return .post
        }
    }
    // 三类请求 1. 必须不带token 请求 2. 必须带token 请求 3. 可带可不带
    
    case endpoint(EndPointProtocol, param: Mappable?)
    case upload(endpoint: EndPointProtocol)
    
    var param: Mappable? {
        switch self {
        case .endpoint(_, let param):
            return param
        default:
            return nil
        }
    }

    func asURLRequest() throws -> URLRequest {
        
        switch self {
        case .endpoint(let path, param: let param):
            var params: [String: Any] = [:]
            if !AppConfig.shared.encrypt {
                params["no_encrypt"] = "1"
            }
            if let dic = param?.toJSON(), !dic.isEmpty {
                for (key, value) in dic {
                    params[key] = value
                }
            }
            let result: (path: String, parameters: [String: Any]?) = (path.URL(), params)
            let URL = Foundation.URL(string: result.path)!
            var URLRequest = Foundation.URLRequest(url: URL)
            URLRequest.httpMethod = method.rawValue
            return try JSONEncoding.default.encode(URLRequest, with: result.parameters).urlRequest!
        case .upload(let path):
            guard var head = Header().toJSON() as? [String: String] else {
                return Foundation.URLRequest(url: Foundation.URL(string: "")!)
            }
            let URL = Foundation.URL(string: path.URL())!
            var URLRequest = Foundation.URLRequest(url: URL)
            URLRequest.httpMethod = method.rawValue
            head.removeValue(forKey: "Content-Type")
            head.forEach { (key, value) in
                URLRequest.setValue(value, forHTTPHeaderField: key)
            }
            
            return try JSONEncoding.default.encode(URLRequest, with: nil).urlRequest!
        }
    }

}

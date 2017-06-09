//
//  RequestManager.swift
//  Bank
//
//  Created by Koh Ryu on 16/4/5.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//
// swiftlint:disable force_unwrapping

import Alamofire
import PromiseKit
import ObjectMapper
import URLNavigator
import Kingfisher
import AlamofireImage
import MBProgressHUD

public enum NeedToken {
    case `true`
    case `false`
    case `default`
}

func handleRequest<T: Mappable>(_ router: Router, needToken: NeedToken = .true) -> Promise<T> {
    return Promise { fulfill, reject in
//        let param = router.param
//        let postData = PostData(param: param, header: router.header)
        var urlRequest = router.urlRequest
        var header = Header().toJSON()
        
        if case .false = needToken {
            header.removeValue(forKey: "APP-TOKEN")
            header.removeValue(forKey: "APP_TOKEN")
        }
        if case .default = needToken, !AppConfig.shared.isLoginFlag {
            header.removeValue(forKey: "APP-TOKEN")
            header.removeValue(forKey: "APP_TOKEN")
        }
        header.forEach { (key, value) in
            if let string = value as? String {
                urlRequest?.setValue(string, forHTTPHeaderField: key)
            }
        }
        let req = request(urlRequest!)
        log.verbose("Request--URL [\(router.urlRequest!.url!.absoluteString)], request header [\(req.request?.allHTTPHeaderFields ?? [:])]")
        req
            .validate()
            .responseString(completionHandler: { (response) in
                log.verbose("Request--URL [\(router.urlRequest!.url!.absoluteString)], response string [\(response.value ?? "null")]")
            })
            .responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let value):
                    let error = AppError(code: RequestErrorCode.unknown, msg: nil)
                    guard let dic = value as? [String: Any] else {
                        reject(error)
                        return
                    }
                    guard let base = Mapper<BaseResponseObject<T>>().map(JSON: dic) else {
                        reject(error)
                        return
                    }
                    if base.isValid == true, let object = Mapper<T>().map(JSON: dic) {
                        log.verbose("Request--URL [\(router.urlRequest!.url!.absoluteString)], response object [\(dic)]")
                        fulfill(object)
                    } else {
                        if base.needRelogin == true, let delegate = UIApplication.shared.delegate as? AppDelegate, let containerVC = delegate.containerVC {
                            log.error("Request--URL [\(router.urlRequest!.url!.absoluteString)], error [need relogin] ")
                            SessionManager.default.session.getAllTasks { tasks in
                                tasks.forEach { $0.cancel() }
                            }
                            containerVC.logout()
                        } else {
                            // 业务逻辑错误
                            let error = AppError(code: base.code, msg: base.msg)
                            reject(error)
                        }
                    }
                case .failure(let error):
                    log.error("Request--URL [\(router.urlRequest!.url!.absoluteString)], error [\(error.localizedDescription)]")
                    reject(error)
                }
            })
//        debugPrint(req)
        
    }
}

func handleUpload(_ router: URLRequestConvertible, param: FileUploadParameter, fileData: [Data]) -> Promise<FileUploadResponse> {
    return Promise { fulfill, reject in
        _ = upload(multipartFormData: { (multipartFormData) in
            fileData.forEach { (data) in
                multipartFormData.append(data, withName: "image[]", fileName: "image.jpg", mimeType: "image/jpeg")
            }
            if let dic = param.toJSON() as? [String: String] {
                for (key, value) in dic {
                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                }
            }
            }, with: router, encodingCompletion: { (result) in
                switch result {
                case .success(let upload, _, _):
                    upload
                        .validate()
                        .responseJSON(completionHandler: { (response) in
                            switch response.result {
                            case .success(let value):
                                guard let base = Mapper<FileUploadResponse>().map(JSONObject: value) else {
                                    let error = AppError(code: RequestErrorCode.unknown, msg: nil)
                                    reject(error)
                                    return
                                }
                                if base.isValid {
                                    fulfill(base)
                                } else {
                                    let error = AppError(code: base.code, msg: base.msg)
                                    if base.needRelogin == true, let delegate = UIApplication.shared.delegate as? AppDelegate, let containerVC = delegate.containerVC {
                                        containerVC.logout()
                                    }
                                    reject(error)
                                }
                            case .failure(let error):
                                reject(error)
                            }
                        })
                case .failure(let error):
                    reject(error)
                }
        })
    }
}

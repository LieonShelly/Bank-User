//
//  RequestError.swift
//  Bank
//
//  Created by Koh Ryu on 16/4/5.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

// swiftlint:disable cyclomatic_complexity

import Foundation

private let domain = "cn.chcts.bank"

protocol ErrorCode {
    func errorCode() -> Int
}

public enum RequestErrorCode: String, ErrorCode {
    case success = "0"
    case wrongIDPass = "01070503"
    case oldPassError = "01074402"
    case userExist = "01071005"
    case imageCaptchaError = "10010009"
    case iamgeCaptchaEmpty = "10010011"
    case payPassError = "01070003"
    case infoError = "103035"
    case payPassLock = "01070002"
    case inputTwoDiffPass = "1302"
    case needEnoughPoint = "1304"
    case needRiskAssess = "203001"
    case answerWrong = "06090404"
    /// 抽奖次数用完 并且已经分享过了
    case countsRunOut = "06060201"
    /// 抽奖次数用完，但可以分享
    case runOutShare = "06060202"
    /// 没有正在进行的活动
    case noneLottery = "06060001"
    case invalidSSHKey = "-10011"
    case needRelogin = "-1002"
    case unknown = "-100"
    
    func errorCode() -> Int {
        return Int(rawValue) ?? -100
    }
}

public enum ValidInputsErrorCode: Int, ErrorCode {
    case emptyAccount
    case emptyPass
    case empty
    /// 不匹配
    case unmatched
    case imageNotFound
    /// 未接受协议
    case notAcceptAgreements
    /// 收货人姓名为空
    case nameEmpty
    /// 收货人电话为空
    case phoneEmpty
    /// 收货人地址为空
    case addressEmpty
    /// 支付密码长度错误
    case payPassLengthError
    /// 支付密码不匹配
    case payPassNotFit
    /// 身份证号长度错误
    case idCardLengthError
    /// 请输入正确的绵商银行卡号
    case inputRightBankCard
    /// 请输入正确的手机号码
    case inputRightPhoneNumber
    /// 请输入银行预留手机号
    case inputReservedPhoneNumber
    /// 用户名格式不对
    case nameFormatError
    /// 请输入正确的姓名
    case nameError
    /// 请输入正确的邮政编码
    case postCodeError
    
    /// 积分超出限制
    case pointLimit
    /// 积分不接受非数字输入
    case pointInvalidInput
    /// 登录密码不规范
    case passwordInputError
    
    func errorCode() -> Int {
        return rawValue
    }
    
    var message: String {
        switch self {
        case .emptyAccount:
            return R.string.localizable.input_empty_account()
        case .emptyPass:
            return R.string.localizable.input_empty_password()
        case .empty:
            return R.string.localizable.input_empty()
        case .unmatched:
            return R.string.localizable.input_notmatch()
        case .imageNotFound:
            return R.string.localizable.input_image_notfound()
        case .notAcceptAgreements:
            return R.string.localizable.input_not_accept_tos()
        case .nameEmpty:
            return R.string.localizable.center_address_nameEmpty()
        case .phoneEmpty:
            return R.string.localizable.center_address_phoneEmpty()
        case .addressEmpty:
            return R.string.localizable.center_address_addressEmpty()
        case .payPassLengthError:
            return R.string.localizable.center_setting_paypassLengthError()
        case .payPassNotFit:
            return R.string.localizable.center_setting_paypassNotFit()
        case .idCardLengthError:
            return R.string.localizable.bank_bind_card_idcardLengthError()
        case .inputRightBankCard:
            return R.string.localizable.bank_bind_card_InPutRightBankCard()
        case .inputRightPhoneNumber:
            return R.string.localizable.bank_bind_card_InPutRightPhoneNumber()
        case .inputReservedPhoneNumber:
            return R.string.localizable.bank_bind_card_InPutReservedPhoneNumber()
        case .nameFormatError:
            return R.string.localizable.alertTitle_userName_format_error()
        case .nameError:
            return R.string.localizable.alertTitle_name_error()
        case .postCodeError:
            return R.string.localizable.alertTitle_postCode_error()
        case .pointLimit:
            return R.string.localizable.input_point_limit()
        case .pointInvalidInput:
            return R.string.localizable.input_point_invalid_input()
        case .passwordInputError:
            return R.string.localizable.alertTitle_password_input_error()
//        default:
//            return ""
        }
    }
}

public struct AppError: Error {
    var errorCode: ErrorCode
    fileprivate var message: String?
    
    init(code: ErrorCode, msg: String? = nil) {
        errorCode = code
        message = msg
    }
    
    func toError() -> NSError {
        if errorCode is RequestErrorCode {
            guard let message = message else {
                return NSError(domain: domain, code: errorCode.errorCode(), userInfo: nil)
            }
            let info = [NSLocalizedDescriptionKey: message] as [AnyHashable: Any]
            return NSError(domain: domain, code: errorCode.errorCode(), userInfo: info)
        }
        if let error = errorCode as? ValidInputsErrorCode {
            return NSError(domain: domain, code: error.errorCode(), userInfo: [NSLocalizedDescriptionKey: error.message])
        }
        return NSError(domain: domain, code: -10000, userInfo: nil)
    }
}

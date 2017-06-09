//
//  NoneView.swift
//  Bank
//
//  Created by 杨锐 on 2016/11/11.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

public enum NoneViewType {
    /// 消费券
    case coupon
    /// 砸金蛋奖品
    case prize
    /// 已完成的活动
    case completeEvent
    /// 未完成的活动
    case unCompleteEvent
    /// 我的任务
    case task
    /// 我的收藏
    case collection
    /// 我的订单
    case order
    /// 优惠买单
    case discount
    /// 现场活动详情
    case offlineEventDetail
    /// 消息中心
    case notifiction
    /// 搜索
    case search
    /// 购物车
    case cart
    /// 银行卡
    case bank
    /// 打赏
    case reward
    /// 地址
    case address
    /// 广告详情
    case advertDetail
    /// 其他无数据页面
    case other
}

class NoneView: UIView {
    
    fileprivate var picImageView: UIImageView!
    fileprivate var wordLabel: UILabel!
    fileprivate var button: UIButton!
    var type: NoneViewType = .coupon
    var buttonHandleBlock: (() -> Void)?
    
    init(frame: CGRect, type: NoneViewType) {
        super.init(frame: frame)
        self.type = type
        self.backgroundColor = UIColor(hex: 0xf5f5f5)
        self.createUI()
        self.configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// 创建视图
    fileprivate func createUI() {
        picImageView = UIImageView()
        addSubview(picImageView)
        
        picImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(100)
            make.centerX.equalTo(self.snp.centerX)
        }
        
        wordLabel = UILabel()
        wordLabel.textAlignment = .center
        wordLabel.textColor = UIColor(hex: 0x5f6983)
        wordLabel.font = UIFont(name: "PingFangSC", size: 18)
//        wordLabel.font = UIFont.systemFont(ofSize: 18)
        addSubview(wordLabel)
        
        wordLabel.snp.makeConstraints { (make) in
            make.top.equalTo(picImageView.snp.bottom).offset(40)
            make.centerX.equalTo(self.snp.centerX)
        }
        
        button = UIButton(type: .custom)
        button.setTitleColor(UIColor(hex: 0x666666), for: UIControlState())
        button.titleLabel?.font = UIFont(name: "PingFangSC", size: 20)
        button.layer.borderColor = UIColor(hex: 0xa0a0a0).cgColor
        button.layer.borderWidth = 0.8
        button.cornerRadius = 20
        addSubview(button)
        
        button.snp.makeConstraints { (make) in
            make.top.equalTo(wordLabel.snp.bottom).offset(40)
            make.height.equalTo(40)
            make.width.equalTo(300)
            make.centerX.equalTo(self.snp.centerX)
        }
        
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        button.isHidden = true
    }
    
    /// 根据类型设置不同的视图
    fileprivate func configUI() {
        switch type {
        case .coupon:
            picImageView.image = R.image.noneCoupon_pic()
            wordLabel.text = R.string.localizable.none_coupon_title()
            button.setTitle(R.string.localizable.none_coupon_button_title(), for: UIControlState())
            button.isHidden = false
        case .prize:
            picImageView.image = R.image.nonedata_image_pic()
            wordLabel.text = R.string.localizable.none_prize_title()
        case .completeEvent:
            picImageView.image = R.image.nonedata_image_pic()
            wordLabel.text = R.string.localizable.none_offlineEvent_title()
            button.setTitle(R.string.localizable.none_offloneEvent_button_title(), for: UIControlState())
            button.isHidden = false
        case .unCompleteEvent:
            picImageView.image = R.image.nonedata_image_pic()
            wordLabel.text = R.string.localizable.none_offlineEvent_title()
            button.setTitle(R.string.localizable.none_offloneEvent_button_title(), for: UIControlState())
            button.isHidden = false
        case .task:
            picImageView.image = R.image.nonedata_image_pic()
            wordLabel.text = R.string.localizable.none_task_title()
            button.setTitle(R.string.localizable.none_task_button_title(), for: UIControlState())
            button.isHidden = false
        case .collection:
            picImageView.image = R.image.nonedata_image_pic()
            wordLabel.text = R.string.localizable.none_collection_title()
            button.setTitle(R.string.localizable.none_collection_button_title(), for: UIControlState())
            button.isHidden = false
        case .order:
            picImageView.image = R.image.nonedata_image_pic()
            wordLabel.text = R.string.localizable.none_order_title()
            button.setTitle(R.string.localizable.none_order_button_title(), for: UIControlState())
            button.isHidden = false
        case .discount:
            picImageView.image = R.image.nonedata_image_pic()
            wordLabel.text = R.string.localizable.none_discount_title()
        case .offlineEventDetail:
            picImageView.image = R.image.mall_offlineEvent_icon_cannot_view()
            wordLabel.text = R.string.localizable.none_event_title()
        case .notifiction:
            picImageView.image = R.image.nonedata_image_pic()
            wordLabel.text = R.string.localizable.none_message_title()
        case .search:
            picImageView.image = R.image.nonedata_image_pic()
            wordLabel.text = R.string.localizable.none_search_title()
        case .cart:
            picImageView.image = R.image.icon_no_commodity()
            wordLabel.text = R.string.localizable.none_goods_title()
        case .bank:
            picImageView.image = R.image.icon_blank_card()
            wordLabel.text = R.string.localizable.none_card_title()
            button.setTitle(R.string.localizable.none_card_button_title(), for: UIControlState())
            button.isHidden = false
        case .reward:
            picImageView.image = R.image.nonedata_image_pic()
            wordLabel.text = R.string.localizable.none_reward_title()
        case .address:
            picImageView.image = R.image.center_address_pic_add_1()
            wordLabel.text = R.string.localizable.none_address_title()
            button.setTitle(R.string.localizable.none_address_button_title(), for: UIControlState())
            button.isHidden = false
        case .advertDetail:
            picImageView.image = R.image.mall_offlineEvent_icon_cannot_view()
            wordLabel.text = R.string.localizable.none_advert_title()
        case .other:
            picImageView.image = R.image.nonedata_image_pic()
            wordLabel.text = R.string.localizable.none_data_title()
        }
    }
    
    @objc fileprivate func buttonAction(_ sender: UIButton) {
        if let block = buttonHandleBlock {
            block()
        }
    }
}

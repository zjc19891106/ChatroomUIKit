//
//  GiftsBarrageBinder.swift
//  ChatroomUIKit_Example
//
//  Created by 朱继超 on 2023/9/4.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import ChatroomUIKit

@objc public class GiftsBarrageBinder: NSObject {
    
    var driver: IGiftsBarrageListDriver?
    
    private weak var giftDelegate: GiftService? {
        didSet {
            giftDelegate?.unbindGiftResponseListener(listener: self)
            giftDelegate?.bindGiftResponseListener(listener: self)
        }
    }

    public func bind(driver: IGiftsBarrageListDriver, giftService: GiftService) {
        self.giftDelegate = giftService
        self.driver = driver
        
    }
}

extension GiftsBarrageBinder: GiftResponseListener {
    
    public func receiveGift(gift: ChatroomUIKit.GiftEntityProtocol) {
        self.driver?.receiveGift(gift: gift)
    }
    
    
}

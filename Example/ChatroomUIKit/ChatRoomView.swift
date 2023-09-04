//
//  ChatRoomView.swift
//  ChatroomUIKit_Example
//
//  Created by 朱继超 on 2023/9/4.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import ChatroomUIKit

class ChatRoomView: UIView {
    
    
    public var service: ChatroomUIKitService?
    
    private lazy var giftBinder: GiftsBarrageBinder = GiftsBarrageBinder()
    
    lazy var giftBarrage: GiftsBarrageList = {
        GiftsBarrageList(frame: .zero)
    }()
    
    lazy var gifts: GiftsView = {
        GiftsView(frame: .zero, gifts: []) { [weak self] entity in
            self?.service?.giftImplement?.sendGift(gift: entity, completion: { error in
                
            })
        }
    }()

    public func bindService(service: ChatroomUIKitService) {
        self.service = service
        if let giftService = service.giftImplement {
            self.giftBinder.bind(driver: self.giftBarrage, giftService: giftService)
        }
        
    }

}

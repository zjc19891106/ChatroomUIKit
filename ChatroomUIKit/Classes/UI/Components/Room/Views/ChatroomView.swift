//
//  ChatroomView.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/8.
//

import UIKit

@objc open class ChatroomView: UIView {
    
    var service: RoomService?
    
    var menus = [ChatBottomItemProtocol]()
    
    var showGiftBarrage = true
    
    var hiddenChat = false

    lazy var giftBarrages: GiftsBarrageList = {
        GiftsBarrageList(frame: CGRect(x: 10, y: 0, width: self.frame.width-100, height: Appearance.giftBarrageRowHeight*2+20),source:self)
    }()
    
    lazy var barrageList: ChatBarrageList = {
        ChatBarrageList(frame: CGRect(x: 0, y: self.showGiftBarrage ? self.giftBarrages.frame.maxY:0, width: self.frame.width-50, height: 200))
    }()
    
    lazy var bottomBar: ChatBottomFunctionBar = {
        ChatBottomFunctionBar(frame: CGRect(x: 0, y: self.frame.height-54-BottomBarHeight, width: self.frame.width, height: 54), datas: self.menus, hiddenChat: self.hiddenChat)
    }()
    
    lazy var inputBar: ChatInputBar = {
        ChatInputBar(frame: CGRect(x: 0, y: self.frame.height, width: self.frame.width, height: 52),text: nil,placeHolder: Appearance.inputPlaceHolder)
    }()
    
    @objc public required convenience init(frame: CGRect,bottom menus: [ChatBottomItemProtocol],showGiftBarrage: Bool = true,hiddenChat: Bool = false) {
        if showGiftBarrage {
            if frame.height < 206 {
                assert(false,"The lower limit of the entire view height must not be less than 206.")
            }
        } else {
            if frame.height < 354 {
                assert(false,"The lower limit of the entire view height must not be less than 354.")
            }
        }
        self.init(frame: frame)
        self.showGiftBarrage = showGiftBarrage
        self.menus = menus
        if showGiftBarrage {
            self.addSubViews([self.giftBarrages,self.barrageList,self.bottomBar,self.inputBar])
        } else {
            self.addSubViews([self.barrageList,self.bottomBar,self.inputBar])
        }
    }
    
    @objc public func connectService(service: RoomService) {
        self.service = service
        self.service?.enterRoom(completion: { error in
            if error == nil {
                
            }
        })
    }

}

extension ChatroomView: GiftsBarrageListDataSource {
    public func rowHeight() -> CGFloat {
        Appearance.giftBarrageRowHeight
    }
}

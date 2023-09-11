//
//  ChatroomView.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/8.
//

import UIKit

@objc open class ChatroomView: UIView {
    
    private var service: RoomService?
    
    private var menus = [ChatBottomItemProtocol]()
    
    private var showGiftBarrage = true
    
    private var hiddenChat = false
    
    private var giftContainers = [GiftsViewController]()
    
    private var giftContainerTitles = [String]()

    private lazy var giftBarrages: GiftsBarrageList = {
        GiftsBarrageList(frame: CGRect(x: 10, y: 0, width: self.frame.width-100, height: Appearance.giftBarrageRowHeight*2+20),source:self)
    }()
    
    private lazy var barrageList: ChatBarrageList = {
        ChatBarrageList(frame: CGRect(x: 0, y: self.showGiftBarrage ? self.giftBarrages.frame.maxY:0, width: self.frame.width-50, height: 200))
    }()
    
    private lazy var bottomBar: ChatBottomFunctionBar = {
        ChatBottomFunctionBar(frame: CGRect(x: 0, y: self.frame.height-54-BottomBarHeight, width: self.frame.width, height: 54), datas: self.menus, hiddenChat: self.hiddenChat)
    }()
    
    private lazy var inputBar: ChatInputBar = {
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
        self.giftContainers = giftContainers
        self.giftContainerTitles = giftContainerTitles
        self.showGiftBarrage = showGiftBarrage
        self.menus = menus
        if showGiftBarrage {
            self.addSubViews([self.giftBarrages,self.barrageList,self.bottomBar,self.inputBar])
        } else {
            self.addSubViews([self.barrageList,self.bottomBar,self.inputBar])
        }
        self.barrageList.addActionHandler(actionHandler: self)
        self.bottomBar.addActionHandler(actionHandler: self)
    }
    
    /// Description This method binds your view to the model it serves. A ChatroomView can only call it once. There is judgment in this method. Calling it multiple times is invalid.
    /// - Parameter service: RoomService
    @objc public func connectService(service: RoomService) {
        if self.service != nil {
            return
        }
        self.service = service
        self.service?.enterRoom(completion: { error in
            if error == nil {
                
            }
        })
    }
    
    /// Description Disconnect room service
    /// - Parameter service: RoomService
    @objc public func disconnectService(service: RoomService) {
        self.service = nil
    }

}

//MARK: - GiftsBarrageListDataSource
extension ChatroomView: GiftsBarrageListDataSource {
    public func rowHeight() -> CGFloat {
        Appearance.giftBarrageRowHeight
    }
}

//MARK: - ChatBarrageActionEventsHandler
extension ChatroomView: ChatBarrageActionEventsHandler {
    
    public func onMessageBarrageLongPressed(message: ChatMessage) {
        if let mute = ChatroomContext.shared?.usersMap?[message.from]?.mute {
            if mute {
                if let index = Appearance.defaultMessageActions.firstIndex(where: { $0.tag == "Mute"
                }) {
                    Appearance.defaultMessageActions[index] = ActionSheetItem(title: "unmute", type: .normal, tag: "unmute")
                }
            } else {
                if let index = Appearance.defaultMessageActions.firstIndex(where: { $0.tag == "unmute"
                }) {
                    Appearance.defaultMessageActions[index] = ActionSheetItem(title: "Mute", type: .normal, tag: "Mute")
                }
            }
            
        }
        DialogManager.shared.showMessageActions(message: message,actions: Appearance.defaultMessageActions) { item in
            switch item.tag {
            case "Translate":
                self.service?.translate(message: message, completion: { error in
                    
                })
            case "Delete":
                self.service?.roomService?.recall(messageId: message.messageId, completion: { error in
                    
                })
            case "Mute":
                self.service?.mute(userId: message.from, completion: { error in
                    
                })
            case "unmute":
                self.service?.unmute(userId: message.from, completion: { error in
                    
                })
            case "Report":
                self.service?.report(message: message, tag: "", reason: "", completion: { error in
                    
                })
            default:
                item.action?(item)
            }
        }
    }
    
    public func onMessageClicked(message: ChatMessage) {
        consoleLogInfo("onMessageClicked:\(message.messageId)", type: .debug)
    }
    
    private func showReport(completion: @escaping (String,String,ChatError?) -> Void) {
//        DialogManager.shared
    }
}

//MARK: - ChatBottomFunctionBarActionEvents
extension ChatroomView: ChatBottomFunctionBarActionEvents {
    
    public func onBottomItemClicked(item: ChatBottomItemProtocol) {
        item.action?(item)
    }
    
    public func onKeyboardWillWakeup() {
        self.inputBar.show()
    }
    
    
}

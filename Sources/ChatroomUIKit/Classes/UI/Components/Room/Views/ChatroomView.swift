//
//  ChatroomView.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/8.
//

import UIKit


/// ChatroomView all action events delegate.
@objc public protocol ChatroomViewActionEventsDelegate {
    
    /// The method called on ChatroomView message barrage clicked.
    /// - Parameter message: `ChatMessage`
    func onMessageBarrageClicked(message: ChatMessage)
    
    /// The method called on ChatroomView message barrage long pressed.
    /// - Parameter message: `ChatMessage`
    func onMessageListBarrageLongPressed(message: ChatMessage)
    
    /// The method called on ChatroomView raise keyboard button clicked.
    func onKeyboardRaiseClicked()
    
    /// The method called on ChatroomView extension view  item clicked that below chat barrages list .
    /// - Parameter item: The item conform `ChatBottomItemProtocol` instance.
    func onExtensionBottomItemClicked(item: ChatBottomItemProtocol)
}

/// ChatroomUIKit's ChatroomView UI component.
@objc open class ChatroomView: UIView {
    
    /// `RoomService`
    public private(set) var service: RoomService?
    
    /// Bottom bar extension view's data source.
    public private(set) var menus = [ChatBottomItemProtocol]()
    
    lazy private var eventHandlers: NSHashTable<ChatroomViewActionEventsDelegate> = NSHashTable<ChatroomViewActionEventsDelegate>.weakObjects()
    
    /// Whether display gift barrages or not on receive gifts.
    public private(set) var showGiftBarrage = true
    
    /// Whether display raise keyboard button or not.
    public private(set) var hiddenChat = false
        
    /// Gift list on receive gift.
    public private(set) lazy var giftBarrages: GiftsBarrageList = {
        GiftsBarrageList(frame: CGRect(x: 10, y: self.touchFrame.minY, width: self.touchFrame.width-100, height: Appearance.giftBarrageRowHeight*2+20),source:self)
    }()
    
    /// Chat barrages list.
    public private(set) lazy var barrageList: ChatBarrageList = {
        ChatBarrageList(frame: CGRect(x: 0, y: self.showGiftBarrage ? self.giftBarrages.frame.maxY:self.touchFrame.minY, width: self.touchFrame.width-50, height: 200))
    }()
    
    /// Bottom function bar below chat barrages list.
    public private(set) lazy var bottomBar: ChatBottomFunctionBar = {
        ChatBottomFunctionBar(frame: CGRect(x: 0, y: self.frame.height-54-BottomBarHeight, width: self.touchFrame.width, height: 54), datas: self.menus, hiddenChat: self.hiddenChat)
    }()
    
    /// Input text menu bar.
    public private(set) lazy var inputBar: ChatInputBar = {
        ChatInputBar(frame: CGRect(x: 0, y: self.frame.height, width: self.touchFrame.width, height: 52),text: nil,placeHolder: Appearance.inputPlaceHolder)
    }()
    
    private var touchFrame = CGRect.zero
    
    /// Chatroom view init method.
    /// - Parameters:
    ///   - frame: CGRect
    ///   - menus: Array<ChatBottomItemProtocol>
    ///   - showGiftBarrage: `Bool` showGiftBarrage value
    ///   - hiddenChat: `Bool` hiddenChat value
    @objc public required convenience init(respondTouch frame: CGRect,bottom menus: [ChatBottomItemProtocol] = [],showGiftBarrage: Bool = true,hiddenChat: Bool = false) {
        if showGiftBarrage {
            if frame.height < 236 {
                assert(false,"The lower limit of the entire view height must not be less than 206.")
            }
        } else {
            if frame.height < 384 {
                assert(false,"The lower limit of the entire view height must not be less than 354.")
            }
        }
        self.init(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: ScreenHeight))
        self.touchFrame = frame
        self.showGiftBarrage = showGiftBarrage
        self.menus = menus
        if showGiftBarrage {
            self.addSubViews([self.giftBarrages,self.barrageList,self.bottomBar,self.inputBar])
        } else {
            self.addSubViews([self.barrageList,self.bottomBar,self.inputBar])
        }
        self.barrageList.addActionHandler(actionHandler: self)
        self.bottomBar.addActionHandler(actionHandler: self)
        self.inputBar.sendClosure = { [weak self] in
            guard let `self` = self else { return }
            self.service?.roomService?.sendMessage(text: $0, roomId: ChatroomContext.shared?.roomId ?? "", completion: { message, error in
                if error == nil {
                    self.barrageList.showNewMessage(message: message)
                } else {
                    consoleLogInfo("Send message failure!\n\(error?.errorDescription ?? "")", type: .debug)
                }
            })
        }

    }
    
    /// This method binds your view to the model it serves. A ChatroomView can only call it once. There is judgment in this method. Calling it multiple times is invalid.
    /// - Parameter service: RoomService
    @objc public func connectService(service: RoomService) {
        if self.service != nil {
            return
        }
        self.service = service
        service.bindChatDriver(driver: self.barrageList)
        if self.showGiftBarrage {
            service.bindGiftDriver(driver: self.giftBarrages)
        }
        service.enterRoom(completion: { [weak self] error in
            if error == nil {
                self?.service?.fetchMuteUsers(pageSize: 100, completion: { _, error in
                    if error != nil {
                        consoleLogInfo("SDK fetch mute users failure!\nError:\(error?.errorDescription ?? "")", type: .debug)
                    }
                })
            }
        })
    }
    
    /// Disconnect room service
    /// - Parameter service: RoomService
    @objc public func disconnectService(service: RoomService) {
        self.service?.leaveRoom(completion: { [weak self] error in
            if error == nil {
                self?.service = nil
            } else {
                consoleLogInfo("SDK leave chatroom failure!\nError:\(error?.errorDescription ?? "")", type: .debug)
            }
        })
    }
    
    
    /// When you want receive chatroom view's touch action events.You can called the method.
    /// - Parameter actionHandler: `ChatroomViewActionEventsDelegate`
    @objc public func addActionHandler(actionHandler: ChatroomViewActionEventsDelegate) {
        if self.eventHandlers.contains(actionHandler) {
            return
        }
        self.eventHandlers.add(actionHandler)
    }
    
    /// When you doesn't want receive chatroom view's touch action events.You can called the method.
    /// - Parameter actionHandler: `ChatroomViewActionEventsDelegate`
    @objc public func removeEventHandler(actionHandler: ChatroomViewActionEventsDelegate) {
        self.eventHandlers.remove(actionHandler)
    }
    

}

//MARK: - GiftsBarrageListDataSource
extension ChatroomView: GiftsBarrageListTransformAnimationDataSource {
    public func rowHeight() -> CGFloat {
        Appearance.giftBarrageRowHeight
    }
}

//MARK: - ChatBarrageActionEventsHandler
extension ChatroomView: ChatBarrageActionEventsHandler {
    
    public func onMessageBarrageLongPressed(message: ChatMessage) {
        if let owner = ChatroomContext.shared?.owner,owner {
            if let map = ChatroomContext.shared?.muteMap {
                let mute = map[message.from] ?? false
                if mute {
                    if let index = Appearance.defaultMessageActions.firstIndex(where: { $0.tag == "Mute"
                    }) {
                        Appearance.defaultMessageActions[index] = ActionSheetItem(title: "barrage_long_press_menu_unmute".chatroom.localize, type: .normal, tag: "unmute")
                    }
                } else {
                    if let index = Appearance.defaultMessageActions.firstIndex(where: { $0.tag == "unmute"
                    }) {
                        Appearance.defaultMessageActions[index] = ActionSheetItem(title: "barrage_long_press_menu_mute".chatroom.localize, type: .normal, tag: "Mute")
                    }
                }
            }
        } else {
            if let index = Appearance.defaultMessageActions.firstIndex(where: { $0.tag == "Mute"
            }) {
                Appearance.defaultMessageActions.remove(at: index)
            }
        }
        for delegate in self.eventHandlers.allObjects {
            delegate.onMessageListBarrageLongPressed(message: message)
        }
    }
    
    private func showLongPressDialog(message: ChatMessage) {
        DialogManager.shared.showMessageActions(actions: Appearance.defaultMessageActions) { [weak self] item in
            switch item.tag {
            case "Translate":
                self?.service?.translate(message: message, completion: { _ in })
            case "Delete":
                self?.service?.roomService?.recall(messageId: message.messageId, completion: { _ in })
            case "Mute":
                self?.service?.mute(userId: message.from, completion: { _ in })
            case "unmute":
                self?.service?.unmute(userId: message.from, completion: { _ in })
            case "Report":
                DialogManager.shared.showReportDialog(message: message)
            default:
                item.action?(item)
            }
        }
    }
    
    public func onMessageClicked(message: ChatMessage) {
        consoleLogInfo("onMessageClicked:\(message.messageId)", type: .debug)
        for delegate in self.eventHandlers.allObjects {
            delegate.onMessageBarrageClicked(message: message)
        }
    }
    
}

//MARK: - ChatBottomFunctionBarActionEvents
extension ChatroomView: ChatBottomFunctionBarActionEvents {
    
    public func onBottomItemClicked(item: ChatBottomItemProtocol) {
        item.action?(item)
        for delegate in self.eventHandlers.allObjects {
            delegate.onExtensionBottomItemClicked(item: item)
        }
    }
    
    public func onKeyboardWillWakeup() {
        self.inputBar.show()
        for delegate in self.eventHandlers.allObjects {
            delegate.onKeyboardRaiseClicked()
        }
    }
    
    
}

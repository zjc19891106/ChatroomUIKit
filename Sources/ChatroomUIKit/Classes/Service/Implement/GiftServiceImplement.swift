//
//  GiftServiceImplement.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/8/31.
//

import UIKit
import KakaJSON

let chatroom_UIKit_gift = "chatroom_UIKit_gift"

@objc public final class GiftServiceImplement: NSObject {
    
    private var currentRoomId: String = ""
        
    public private(set) var responseDelegates: NSHashTable<GiftResponseListener> = NSHashTable<GiftResponseListener>.weakObjects()

    @objc public init(roomId: String) {
        self.currentRoomId = roomId
        super.init()
        ChatClient.shared().chatManager?.add(self, delegateQueue: .main)
    }
    
    @objc public func notifyGiftDriverShowSelfSend(gift: GiftEntityProtocol) {
        for response in self.responseDelegates.allObjects {
            response.receiveGift(gift: gift)
        }
    }
}
//MARK: - GiftService
extension GiftServiceImplement: GiftService {
    
    public func sendGift(gift: GiftEntityProtocol, completion: @escaping (ChatError?) -> Void) {
        let gift = gift as? GiftEntity
        let user = ChatroomContext.shared?.currentUser as? User
        let message = ChatMessage(conversationID: self.currentRoomId, body: ChatCustomMessageBody(event: chatroom_UIKit_gift, customExt: ["gift" : gift?.kj.JSONString() ?? ""]), ext: user?.kj.JSONObject())
        message.chatType = .chatRoom
        ChatClient.shared().chatManager?.send(message, progress: nil,completion: { chatMessage, error in
            completion(error)
        })
    }
    
    public func bindGiftResponseListener(listener: GiftResponseListener) {
        if self.responseDelegates.contains(listener) {
            return
        }
        self.responseDelegates.add(listener)
    }
    
    public func unbindGiftResponseListener(listener: GiftResponseListener) {
        if self.responseDelegates.contains(listener) {
            self.responseDelegates.remove(listener)
        }
    }
}
//MARK: - EMChatManagerDelegate
extension GiftServiceImplement: ChatManagerDelegate {
    
    public func messagesDidReceive(_ aMessages: [ChatMessage]) {
        for message in aMessages {
            for response in self.responseDelegates.allObjects {
                switch message.body.type {
                case .custom:
                    if let body = message.body as? ChatCustomMessageBody {
                        if body.event == chatroom_UIKit_gift,let json = message.ext as? [String:Any] {
                            let user = model(from: json, type: User.self)
                            if let userInfo = user as? UserInfoProtocol,let jsonString = body.customExt["gift"] {
                                let json = jsonString.chatroom.jsonToDictionary()
                                let model = model(from: json, type: GiftEntity.self)
                                if let gift = model as? GiftEntityProtocol {
                                    gift.sendUser = userInfo
                                    response.receiveGift(gift: gift)
                                }

                            }
                        }
                    }
                default:
                    break
                }
            }
        }
    }
}

@objc public class GiftEntity:NSObject,GiftEntityProtocol,Convertible {
    
    public var giftId: String = ""
    
    public var giftName: String = ""
    
    public var giftPrice: String = ""
    
    public var giftCount: String = "1"
    
    public var giftIcon: String = ""
    
    public var giftEffect: String = ""
    
    public var selected: Bool = false
    
    public var sentThenClose: Bool = true
    
    public var sendUser: UserInfoProtocol?
    
    required public override init() {
        
    }
    
    public func kj_modelKey(from property: Property) -> ModelPropertyKey {
        property.name
    }
}

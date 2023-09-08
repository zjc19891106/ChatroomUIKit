//
//  RoomService.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/8.
//

import UIKit

@objc open class RoomService: NSObject {
    
    var roomId = ""
    
    lazy var giftService: GiftService? = nil
    
    lazy var roomService: ChatroomService = ChatroomServiceImplement()
    
    public required init(roomId: String) {
        self.roomId = roomId
    }
    
    func enterRoom(completion: @escaping (ChatError?) -> Void) {
        if let userId = ChatroomContext.shared?.currentUser?.userId  {
            self.roomService.chatroomOperating(roomId: self.roomId, userId: userId, type: .join) { [weak self] success, error in
                guard let `self` = self else { return  }
                if !success {
                    consoleLogInfo("Joined chatroom error:\(error?.errorDescription ?? "")", type: .debug)
                } else {
                    self.giftService = GiftServiceImplement(roomId: self.roomId)
                }
                completion(error)
            }
        }
    }
    
    func leaveRoom(completion: @escaping (ChatError?) -> Void) {
        self.roomService.chatroomOperating(roomId: self.roomId, userId: ChatClient.shared().currentUsername ?? "", type: .leave, completion: { success, error in
            if success {
                self.roomId = ""
            }
        })
    }
}

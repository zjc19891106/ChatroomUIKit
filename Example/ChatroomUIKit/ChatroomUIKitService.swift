//
//  ChatroomUIKitService.swift
//  ChatroomUIKit_Example
//
//  Created by 朱继超 on 2023/9/4.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import ChatroomUIKit

class CustomInfo:NSObject, UserInfoProtocol {
    var identify: String = ""
    
    var userId: String = "123"
    
    var nickName: String = "aaa"
    
    var avatarURL: String = ""
    
    var gender: Int = 1
    
    
}

open class ChatroomUIKitService: NSObject {
    
    var roomId = ""
    
    var token = ""
        
    lazy var userImplement: UserServiceProtocol? = {
        UserServiceImplement(userInfo: ChatroomContext.shared!.currentUser!, token: self.token,use: true) { error in
            
        }
    }()
    
    lazy var chatroomImplement: ChatroomService? = {
        ChatroomServiceImplement(chatroomId: self.roomId) { error in
            
        }
    }()
    
    lazy var giftImplement: GiftService? = {
        GiftServiceImplement(gifts: [], roomId: self.roomId)
    }()
    
    public init(roomId: String,token: String,user: UserInfoProtocol) {
        super.init()
        self.roomId = roomId
        self.token = token
        ChatroomContext.shared?.currentUser = user
        self.userImplement?.login(userId: user.userId, token: token, completion: { [weak self] success, error in
            if error != nil {
                consoleLogInfo("\(error?.errorDescription ?? "")", type: .debug)
            } else {
                _ = self?.chatroomImplement
                _ = self?.giftImplement
            }
        })
    }
    
//    public func destroyed(completion: @escaping (ChatError?) -> Void) {
//        self.roomId = ""
//        self.token = ""
//        self.chatroomImplement?.chatroomOperating(roomId: self.roomId, userId:  ChatroomContext.shared?.currentUser?.userId ?? "", type: .leave) { [weak self] success, error in
//            if error == nil {
//                self?.userImplement?.logout { result, resultError in
//                    completion(resultError)
//                }
//            } else {
//                completion(error)
//            }
//        }
//
//    }
    
    func switchRoom(roomId: String) {
        self.chatroomImplement?.chatroomOperating(roomId: self.roomId, userId: ChatroomContext.shared?.currentUser?.userId ?? "", type: .leave, completion: { [weak self] success, error in
            if error == nil {
                self?.roomId = roomId
                self?.chatroomImplement?.chatroomOperating(roomId: roomId, userId: ChatroomContext.shared?.currentUser?.userId ?? "", type: .join, completion: { result, error in
                    
                })
            }
            
        })
    }
        
}

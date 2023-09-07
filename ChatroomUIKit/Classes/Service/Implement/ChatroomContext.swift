//
//  ChatroomContext.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/8/31.
//

import UIKit

@objcMembers public final class ChatroomContext: NSObject {
    
    public static let shared: ChatroomContext? = ChatroomContext()
    
    public var currentUser: User? {
        willSet {
            if let user = newValue {
                self.usersMap?[user.userId] = user
            }
        }
    }
    
    public var owner: UserInfoProtocol?
    
    public var room: ChatRoom?
    
    public var usersMap: Dictionary<String,User>? = Dictionary<String,User>()
}

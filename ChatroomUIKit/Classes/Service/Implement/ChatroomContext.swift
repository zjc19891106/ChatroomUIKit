//
//  ChatroomContext.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/8/31.
//

import UIKit
/**
 A singleton class that represents the context of a chatroom. It contains information about the current user, the owner of the chatroom, the mute map, the room ID, and a dictionary of users in the chatroom.
 */

@objcMembers public final class ChatroomContext: NSObject {
    
    public static let shared: ChatroomContext? = ChatroomContext()
    
    public var currentUser: UserInfoProtocol? {
        willSet {
            if let user = newValue {
                self.usersMap?[user.userId] = user
            }
        }
    }
    
    public var owner: UserInfoProtocol?
    
    public var muteMap: Dictionary<String,Bool>? = Dictionary<String,Bool>()
    
    public var roomId: String?
    
    public var usersMap: Dictionary<String,UserInfoProtocol>? = Dictionary<String,UserInfoProtocol>()
}

//
//  ChatroomContext.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/8/31.
//

import UIKit
import HyphenateChat

@objc public final class ChatroomContext: NSObject {
    
    static let shared: ChatroomContext? = ChatroomContext()
    
    var currentUser: UserInfoProtocol?
    
    var owner: UserInfoProtocol?
    
    var room: EMChatroom?
    
    var usersMap: [String:UserInfoProtocol]? = [String:UserInfoProtocol]()
}

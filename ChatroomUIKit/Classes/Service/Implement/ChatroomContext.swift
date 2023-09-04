//
//  ChatroomContext.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/8/31.
//

import UIKit

@objcMembers public final class ChatroomContext: NSObject {
    
    public static let shared: ChatroomContext? = ChatroomContext()
    
    public var currentUser: UserInfoProtocol?
    
    public var owner: UserInfoProtocol?
    
    public var room: ChatRoom?
    
    public var usersMap: [String:UserInfoProtocol]? = [String:UserInfoProtocol]()
}

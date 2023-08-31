//
//  ChatService.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/8/28.
//

import Foundation


/// Description Chatroom user operation events.
@objc public enum ChatroomUserOperationType: Int {
    case addAdministrator
    case removeAdministrator
    case mute
    case unmute
    case block
    case unblock
}

/// Description Chatroom operation events.Ext,leave or join.
@objc public enum ChatroomOperationType: Int {
    case join
    case leave
}


@objc public protocol ChatroomService: NSObjectProtocol {
    
    /// Description Binding a listener to receive callback events.
    /// - Parameter response: ChatResponseListener
    func bindResponse(response: ChatroomResponseListener)
    
    /// Description Unbind the listener.
    /// - Parameter response: ChatResponseListener
    func unbindResponse(response: ChatroomResponseListener)
    
    /// Description Chatroom operation events.
    /// - Parameters:
    ///   - roomId: chatroom id
    ///   - userId: user id
    ///   - type: ChatroomOperationType
    ///   - completion: callback,what if success or error.
    func chatroomOperating(roomId: String, userId: String, type: ChatroomOperationType, completion: @escaping (Bool,ChatError?) -> Void)
    
    
//    /// Description  Destroy a chat room.
//    /// - Parameters:
//    ///   - roomId: chatroom id
//    ///   - completion: Destroyed callback,what if success or error.
//    func destroyedChatRoom(roomId: String, completion: @escaping (Bool,ChatError?) -> Void)
    
    /// Description Get chatroom announcement.
    func announcement(roomId: String, completion: @escaping (String?,ChatError?) -> Void)
    
    /// Description Update chatroom announcement
    /// - Parameters:
    ///   - roomId: chatroom id
    ///   - announcement: announcement content
    ///   - completion: Updated callback,what if success or error.
    func updateAnnouncement(roomId: String, announcement: String, completion: @escaping (Bool,ChatError?) -> Void)
    
    
    /// Description Various operations of group owners or administrators on users.
    /// - Parameters:
    ///   - roomId: chatroom id
    ///   - userId: user id
    ///   - type: ChatroomUserOperationType
    ///   - completion: callback,what if success or error.
    func operatingUser(roomId: String, userId: String, type: ChatroomUserOperationType, completion: @escaping (Bool,ChatError?) -> Void)
    
    /// Description Send text message to chatroom.
    /// - Parameters:
    ///   - text: You'll send text.
    ///   - roomId: chatroom id
    ///   - completion: Send callback,what if success or error.
    func sendMessage(text: String, roomId: String, completion: @escaping (Bool,ChatError?) -> Void)
    
    /// Description Send targeted text messages to some members of the chat room
    /// - Parameters:
    ///   - userIds: [UserId]
    ///   - roomId: chatroom id
    ///   - content: content text
    ///   - completion: Send callback,what if success or error.
    func sendMessage(to userIds:[String], roomId: String, content: String, completion: @escaping (Bool,ChatError?) -> Void)
    
    /// Description Send targeted custom messages to some members of the chat room
    /// - Parameters:
    ///   - userIds: userIds description
    ///   - roomId: [UserId]
    ///   - eventType: A constant String value that identifies the type of event.
    ///   - infoMap: Extended Information
    ///   - completion: Send callback,what if success or error.
    func sendCustomMessage(to userIds:[String], roomId: String, eventType: String, infoMap:[String:String], completion: @escaping (Bool,ChatError?) -> Void)
    
        
}


@objc public protocol ChatroomResponseListener:NSObjectProtocol {
    
    /// Description Received message from chatroom members.
    /// - Parameters:
    ///   - roomId: chatroom id
    ///   - message: EMChatMessage
    func onMessageReceived(roomId: String,message: ChatMessage)
    
    /// Description When a user joins a chatroom.The method carry user info for display.
    /// - Parameters:
    ///   - roomId: chatroom id
    ///   - user: UserInfoProtocol
    func onUserJoined(roomId: String, user: UserInfoProtocol)
    
    /// Description When some user leave chatroom.
    /// - Parameters:
    ///   - roomId: chatroom id
    ///   - userId: user id
    func onUserLeave(roomId: String,userId: String)
    
    /// Description When chatroom announcement updated.The method will called.
    /// - Parameters:
    ///   - roomId: chatroom id
    ///   - announcement: announcement
    func onAnnouncementUpdate(roomId: String,announcement: String)
    
    /// Description When some user kicked out by owner.
    /// - Parameters:
    ///   - roomId: chatroom id
    ///   - userId: user id
    ///   - reason: reason
    func onUserBeKicked(roomId: String, reason: ChatroomBeKickedReason)
}



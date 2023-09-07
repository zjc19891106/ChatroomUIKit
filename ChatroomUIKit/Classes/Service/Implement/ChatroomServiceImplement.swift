//
//  ChatServiceImplement.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/8/31.
//

import UIKit
import HyphenateChat
import KakaJSON

fileprivate let chatroom_UIKit_user_join = "chatroom_UIKit_user_join"

@objc public final class ChatroomServiceImplement: NSObject {
            
    private var responseDelegates: NSHashTable<ChatroomResponseListener> = NSHashTable<ChatroomResponseListener>.weakObjects()
    
    @objc public init(chatroomId: String, completion:@escaping (ChatError?) -> Void) {
        super.init()
        if let userId = ChatroomContext.shared?.currentUser?.userId  {
            self.chatroomOperating(roomId: chatroomId, userId: userId, type: .join) { success, error in
                if !success {
                    consoleLogInfo("Joined chatroom error:\(error?.errorDescription ?? "")", type: .debug)
                } else {
                    ChatClient.shared().roomManager?.add(self, delegateQueue: .main)
                    ChatClient.shared().chatManager?.add(self, delegateQueue: .main)
                }
                completion(error)
            }
        }
    }

    deinit {
        ChatClient.shared().roomManager?.remove(self)
        ChatClient.shared().removeDelegate(self)
    }
}
//MARK: - ChatroomService
extension ChatroomServiceImplement: ChatroomService {
    
    public func bindResponse(response: ChatroomResponseListener) {
        if self.responseDelegates.contains(response) {
            return
        }
        self.responseDelegates.add(response)
    }
    
    public func unbindResponse(response: ChatroomResponseListener) {
        if self.responseDelegates.contains(response) {
            self.responseDelegates.remove(response)
        }
    }
    
    public func chatroomOperating(roomId: String, userId: String, type: ChatroomOperationType, completion: @escaping (Bool, ChatError?) -> Void) {
        switch type {
        case .join:
            ChatClient.shared().roomManager?.joinChatroom(roomId,completion: { [weak self] room, error in
                if error != nil {
                    completion(false,error)
                } else {
                    self?.sendJoinMessage(roomId: room?.chatroomId ?? "", completion: { error in
                        completion(error == nil,error)
                    })
                }
            })
        case .leave:
            ChatClient.shared().roomManager?.leaveChatroom(roomId,completion: { error in
                completion(error == nil,error)
            })
        }
    }
    
    public func announcement(roomId: String, completion: @escaping (String?, ChatError?) -> Void) {
        
        ChatClient.shared().roomManager?.getChatroomAnnouncement(withId: roomId,completion: { content, error in
            completion(content,error)
        })
    }
    
    public func updateAnnouncement(roomId: String, announcement: String, completion: @escaping (Bool, ChatError?) -> Void) {
        ChatClient.shared().roomManager?.updateChatroomAnnouncement(withId: roomId, announcement: announcement,completion: { room, error in
            completion(error == nil,error)
        })
    }
    
    public func operatingUser(roomId: String, userId: String, type: ChatroomUserOperationType, completion: @escaping (Bool, ChatError?) -> Void) {
        switch type {
        case .addAdministrator:
            ChatClient.shared().roomManager?.addAdmin(userId, toChatroom: roomId,completion: { room, error in
                completion(error == nil,error)
            })
        case .removeAdministrator:
            ChatClient.shared().roomManager?.removeAdmin(userId, fromChatroom: roomId,completion: { room, error in
                completion(error == nil,error)
            })
        case .block:
            ChatClient.shared().roomManager?.blockMembers([userId], fromChatroom: roomId,completion: { room, error in
                completion(error == nil,error)
            })
        case .unblock:
            ChatClient.shared().roomManager?.unblockMembers([userId], fromChatroom: roomId,completion: { room, error in
                completion(error == nil,error)
            })
        case .mute:
            ChatClient.shared().roomManager?.muteMembers([userId], muteMilliseconds: 999999, fromChatroom: roomId,completion: { room, error in
                completion(error == nil,error)
            })
        case .unmute:
            ChatClient.shared().roomManager?.unmuteMembers([userId], fromChatroom: roomId,completion: { room, error in
                completion(error == nil,error)
            })
        default:
            break
        }
    }
    
    public func sendMessage(text: String, roomId: String, completion: @escaping (Bool, ChatError?) -> Void) {
        let user = ChatroomContext.shared?.currentUser as? User
        let message = ChatMessage(conversationID: roomId, body: EMTextMessageBody(text: text), ext: user?.kj.JSONObject())
        message.chatType = .chatRoom
        ChatClient.shared().chatManager?.send(message, progress: nil,completion: { chatMessage, error in
            completion(error == nil,error)
        })
    }
    
    public func sendMessage(to userIds: [String], roomId: String, content: String, completion: @escaping (Bool, ChatError?) -> Void) {
        let user = ChatroomContext.shared?.currentUser as? User
        let message = ChatMessage(conversationID: roomId, body: EMTextMessageBody(text: content), ext: user?.kj.JSONObject())
        message.chatType = .chatRoom
        message.receiverList = userIds
        ChatClient.shared().chatManager?.send(message, progress: nil,completion: { chatMessage, error in
            completion(error == nil,error)
        })
    }
    
    public func sendCustomMessage(to userIds: [String], roomId: String, eventType: String, infoMap: [String : String], completion: @escaping (Bool, ChatError?) -> Void) {
        let user = ChatroomContext.shared?.currentUser as? User
        let message = ChatMessage(conversationID: roomId, body: EMCustomMessageBody(event: eventType, customExt: infoMap), ext: user?.kj.JSONObject())
        message.chatType = .chatRoom
        message.receiverList = userIds
        ChatClient.shared().chatManager?.send(message, progress: nil,completion: { chatMessage, error in
            completion(error == nil,error)
        })
    }
    
    public func translateMessage(message: ChatMessage, completion: @escaping (Bool, ChatError?) -> Void) {
        ChatClient.shared().chatManager?.translate(message, targetLanguages: [Appearance.targetLanguage.rawValue],completion: { chatMessage, error in
            completion(error == nil,error)
        })
    }
    
    private func sendJoinMessage(roomId: String, completion: @escaping (ChatError?) -> Void) {
        let user = ChatroomContext.shared?.currentUser as? User
        let message = ChatMessage(conversationID: roomId, body: EMCustomMessageBody(event: chatroom_UIKit_user_join, customExt: nil), ext: user?.kj.JSONObject())
        message.chatType = .chatRoom
        ChatClient.shared().chatManager?.send(message, progress: nil,completion: { chatMessage, error in
            completion(error)
        })
    }
}
//MARK: - ChatRoomManagerDelegate
extension ChatroomServiceImplement: ChatroomManagerDelegate {
    
    public func didDismiss(from aChatroom: ChatRoom, reason aReason: ChatroomBeKickedReason) {
        for response in self.responseDelegates.allObjects {
            if let roomId = aChatroom.chatroomId,let userMap = ChatroomContext.shared?.usersMap {
                if userMap.keys.contains(where: { $0 == ChatroomContext.shared?.currentUser?.userId ?? "" }) {
                    ChatroomContext.shared?.usersMap?.removeValue(forKey: ChatroomContext.shared?.currentUser?.userId ?? "")
                }
                response.onUserBeKicked(roomId: roomId, reason: aReason)
            }
        }
    }
    
    public func chatroomAnnouncementDidUpdate(_ aChatroom: ChatRoom, announcement aAnnouncement: String?) {
        for response in self.responseDelegates.allObjects {
            if let announcement = aAnnouncement,let roomId = aChatroom.chatroomId {
                response.onAnnouncementUpdate(roomId: roomId, announcement: announcement)
            }
        }
    }
    
    public func userDidLeave(_ aChatroom: ChatRoom, user aUsername: String) {
        for response in self.responseDelegates.allObjects {
            if let roomId = aChatroom.chatroomId,let userMap = ChatroomContext.shared?.usersMap {
                if userMap.keys.contains(where: { $0 == aUsername }) {
                    ChatroomContext.shared?.usersMap?.removeValue(forKey: aUsername)
                }
                response.onUserLeave(roomId: roomId, userId: aUsername)
            }
        }
    }
    
}
//MARK: - EMChatManagerDelegate
extension ChatroomServiceImplement: ChatManagerDelegate {
    
    public func messagesDidReceive(_ aMessages: [ChatMessage]) {
        for message in aMessages {
            for response in self.responseDelegates.allObjects {
                switch message.body.type {
                case .text:
                    if let json = message.ext as? [String:Any] {
                        if let user = model(from: json, type: User.self) as? User {
                            ChatroomContext.shared?.usersMap?[user.userId] = user
                        }
                    }
                    response.onMessageReceived(roomId: message.to, message: message)
                case .custom:
                    if let body = message.body as? ChatCustomMessageBody {
                        if body.event == chatroom_UIKit_user_join,let json = message.ext as? [String:Any] {
                            if let user = model(from: json, type: User.self) as? User {
                                ChatroomContext.shared?.usersMap?[user.userId] = user
                                response.onUserJoined(roomId: message.to, user: user)
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



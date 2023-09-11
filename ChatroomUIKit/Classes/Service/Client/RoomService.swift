//
//  RoomService.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/8.
//

import UIKit

@objc open class RoomService: NSObject {
    
    var roomId = ""
    
    var pageNum = 1
    
    lazy var giftService: GiftService? = nil
    
    lazy var roomService: ChatroomService? = ChatroomServiceImplement()
    
    private weak var chatDriver: IChatBarrageListDriver?
    
    private weak var giftDriver: IGiftsBarrageListDriver?
    
    public required init(roomId: String) {
        self.roomId = roomId
    }
    
    @objc public func bindChatDriver(driver: IChatBarrageListDriver) {
        self.chatDriver = driver
    }
    
    @objc public func bindGiftDriver(driver: IGiftsBarrageListDriver) {
        self.giftDriver = driver
    }
    //MARK: - Room operation
    @objc public func enterRoom(completion: @escaping (ChatError?) -> Void) {
        if let userId = ChatroomContext.shared?.currentUser?.userId  {
            self.roomService?.chatroomOperating(roomId: self.roomId, userId: userId, type: .join) { [weak self] success, error in
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
    
    @objc public func leaveRoom(completion: @escaping (ChatError?) -> Void) {
        self.roomService?.chatroomOperating(roomId: self.roomId, userId: ChatClient.shared().currentUsername ?? "", type: .leave, completion: { success, error in
            if success {
                self.roomId = ""
            }
        })
    }
    //MARK: - Participants operation
    @objc public func kick(userId: String,completion: @escaping (ChatError?) -> Void) {
        self.roomService?.operatingUser(roomId: self.roomId, userId: userId, type: .kick, completion: { success, error in
            completion(error)
        })
    }
    
    @objc public func mute(userId: String,completion: @escaping (ChatError?) -> Void) {
        self.roomService?.operatingUser(roomId: self.roomId, userId: userId, type: .mute, completion: { success, error in
            completion(error)
        })
    }
    
    @objc public func unmute(userId: String,completion: @escaping (ChatError?) -> Void) {
        self.roomService?.operatingUser(roomId: self.roomId, userId: userId, type: .mute, completion: { success, error in
            completion(error)
        })
    }
    
    @objc public func block(userId: String,completion: @escaping (ChatError?) -> Void) {
        self.roomService?.operatingUser(roomId: self.roomId, userId: userId, type: .block, completion: { success, error in
            completion(error)
        })
    }
    
    @objc public func unblock(userId: String,completion: @escaping (ChatError?) -> Void) {
        self.roomService?.operatingUser(roomId: self.roomId, userId: userId, type: .unblock, completion: { success, error in
            completion(error)
        })
    }
    
    @objc public func addAdmin(userId: String,completion: @escaping (ChatError?) -> Void) {
        self.roomService?.operatingUser(roomId: self.roomId, userId: userId, type: .addAdministrator, completion: { success, error in
            completion(error)
        })
    }
    
    @objc public func removeAdmin(userId: String,completion: @escaping (ChatError?) -> Void) {
        self.roomService?.operatingUser(roomId: self.roomId, userId: userId, type: .removeAdministrator, completion: { success, error in
            completion(error)
        })
    }
    
    @objc public func translate(message: ChatMessage,completion: @escaping (ChatError?) -> Void) {
        self.roomService?.translateMessage(message: message, completion: { [weak self] translateResult, error in
            if error == nil,let translation = translateResult {
                self?.chatDriver?.refreshMessage(message: translation)
            }
            completion(error)
        })
    }
    
    @objc public func recall(message: ChatMessage,completion: @escaping (ChatError?) -> Void) {
        self.roomService?.recall(messageId: message.messageId, completion: { error in
            completion(error)
        })
    }
    
    @objc public func report(message: ChatMessage,tag: String, reason: String,completion: @escaping (ChatError?) -> Void) {
        self.roomService?.report(messageId: message.messageId, tag: tag, reason: reason, completion: completion)
    }
    
    @objc public func fetchParticipants(pageSize: UInt, completion: @escaping (([UserInfoProtocol]?,ChatError?)->Void)) {
        self.roomService?.fetchParticipants(roomId: self.roomId, pageSize: pageSize, completion: { userIds, error in
            if let ids = userIds {
                var unknownUserIds = [String]()
                for userId in ids {
                    if ChatroomContext.shared?.usersMap?[userId] == nil {
                        unknownUserIds.append(userId)
                    }
                }
                if unknownUserIds.count > 0,RoomUIKitClient.shared.useProperties {
                    RoomUIKitClient.shared.userImplement?.userInfos(userIds: unknownUserIds, completion: { infos, error in
                        if error == nil {
                            var users = [UserInfoProtocol]()
                            for userId in ids {
                                if let user = ChatroomContext.shared?.usersMap?[userId] {
                                    users.append(user)
                                }
                            }
                            completion(users,error)
                        } else {
                            completion(nil,error)
                        }
                    })
                } else {
                    var users = [UserInfoProtocol]()
                    for userId in ids {
                        if let user = ChatroomContext.shared?.usersMap?[userId] {
                            users.append(user)
                        } else {
                            let user = User()
                            user.userId = userId
                            users.append(user)
                        }
                    }
                    completion(users,error)
                }
            }
        })
    }
    
    @objc public func fetchMuteUsers(pageSize: UInt, completion: @escaping (([UserInfoProtocol]?,ChatError?)->Void)) {
        self.roomService?.fetchMuteUsers(roomId: self.roomId, pageNum: UInt(self.pageNum), pageSize: pageSize, completion: { userIds, error in
            if let ids = userIds {
                var unknownUserIds = [String]()
                for userId in ids {
                    if ChatroomContext.shared?.usersMap?[userId] == nil {
                        unknownUserIds.append(userId)
                    }
                }
                if unknownUserIds.count > 0,RoomUIKitClient.shared.useProperties {
                    RoomUIKitClient.shared.userImplement?.userInfos(userIds: unknownUserIds, completion: { infos, error in
                        if error == nil {
                            var users = [UserInfoProtocol]()
                            for userId in ids {
                                if let user = ChatroomContext.shared?.usersMap?[userId] {
                                    users.append(user)
                                }
                            }
                            completion(users,error)
                        } else {
                            completion(nil,error)
                        }
                    })
                } else {
                    var users = [UserInfoProtocol]()
                    for userId in ids {
                        if let user = ChatroomContext.shared?.usersMap?[userId] {
                            users.append(user)
                        } else {
                            let user = User()
                            user.userId = userId
                            users.append(user)
                        }
                    }
                    completion(users,error)
                }
            }
        })
    }
}

extension RoomService: ChatroomResponseListener {
    
    public func onMessageRecalled(roomId: String, message: ChatMessage, by userId: String) {
        if roomId == self.roomId {
            self.chatDriver?.refreshMessage(message: message)
        }
    }
    
    public func onGlobalNotifyReceived(roomId: String, notifyMessage: ChatMessage) {
        
    }
    
    public func onMessageReceived(roomId: String, message: ChatMessage) {
        if roomId == self.roomId {
            self.chatDriver?.showNewMessage(message: message)
        }
    }
        
    public func onUserJoined(roomId: String, user: UserInfoProtocol) {
        
    }
    
    public func onUserLeave(roomId: String, userId: String) {
        if roomId == self.roomId {
            ChatroomContext.shared?.usersMap?.removeValue(forKey: userId)
        }
    }
    
    public func onAnnouncementUpdate(roomId: String, announcement: String) {
        
    }
    
    public func onUserBeKicked(roomId: String, reason: ChatroomBeKickedReason) {
        switch reason {
        case .beRemoved:
            consoleLogInfo("You were kicked chatroom!", type: .debug)
            self.clean()
        case .destroyed:
            consoleLogInfo("The chatroom be destroyed!", type: .debug)
            self.clean()
        case .offline:
            consoleLogInfo("You were offline!", type: .debug)
        default:
            break
        }
    }
    
    private func clean() {
        self.roomService = nil
        self.giftService = nil
        self.chatDriver = nil
        self.giftDriver = nil
        self.roomId = ""
    }
}


extension RoomService: GiftResponseListener {
    
    public func receiveGift(gift: GiftEntityProtocol) {
        self.giftDriver?.receiveGift(gift: gift)
    }
    
}

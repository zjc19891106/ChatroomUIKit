//
//  RoomService.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/8.
//

import UIKit

@objc public enum RoomEventsError: UInt {
    case join
    case leave
    case kick
    case mute
    case unmute
    case translate
    case recall
    case report
    case fetchParticipants
    case fetchMutes
}

/// All events listener of chatroom.
@objc public protocol RoomEventsListener: NSObjectProtocol {
    
    /// This function will be called when the network link status changes.
    /// - Parameter state: ConnectionState
    func onSocketConnectionStateChanged(state: ConnectionState)
    
    /// Token expired you were logout.You need fetch token from your server then call `RoomUIKitClient.shared.login(with userId: "user id", token: "token", completion: <#T##(ChatError?) -> Void#>)` method.
    func onUserTokenDidExpired()
    
    /// Token will expire.If this process takes more than two minutes, the server will kick the user out of the chat room and you will need to rejoin the chat room.You  need fetch token from server then call `RoomUIKitClient.shared.refreshToken(token: "token")`.
    func onUserTokenWillExpired()
    
    /// If you do not set up multi-device login in the Chat service provider's application configuration service, and the user logs in to the same account on other devices, the current device will be kicked offline.
    /// - Parameter device: other device name
    func onUserLoginOtherDevice(device: String)
    
    /// The method called on user unmuted.
    /// - Parameters:
    ///   - roomId: Chatroom id
    ///   - userId: User id
    ///   - operatorId: Operator id
    func onUserUnmuted(roomId: String, userId: String, operatorId: String)
    
    /// The method called on user muted.
    /// - Parameters:
    ///   - roomId: Chatroom id
    ///   - userId: User id
    ///   - operatorId: Operator id
    func onUserMuted(roomId: String, userId: String, operatorId: String)
    
    /// The method called on user joined chatroom.
    /// - Parameters:
    ///   - roomId: Chatroom id
    ///   - user: UserInfoProtocol
    func onUserJoined(roomId: String, user: UserInfoProtocol)
    
    /// The method called on user kicked out chatroom.
    /// - Parameters:
    ///   - roomId: Chatroom id
    ///   - reason: ChatroomBeKickedReason
    func onUserBeKicked(roomId: String, reason: ChatroomBeKickedReason)
    
    /// The method called on receive global notify message.
    /// - Parameter message: ChatMessage
    func onReceiveGlobalNotify(message: ChatMessage)
    
    /// The method called on chatroom announcement updated.
    /// - Parameters:
    ///   - roomId: Chatroom id
    ///   - announcement: Announcement text
    func onAnnouncementUpdate(roomId: String, announcement: String)
    
    /// The method called on  some chatroom events error occured.
    /// - Parameters:
    ///   - error: ChatError
    ///   - type: RoomEventsError
    func onErrorOccur(error: ChatError,type: RoomEventsError)
}

/// Chat room hub service transfer class in chat room UIKit.
@objc open class RoomService: NSObject {
    
    /// Events listener of chatroom.
    public private(set) var eventsListener: NSHashTable<RoomEventsListener> = NSHashTable<RoomEventsListener>.weakObjects()
    
    /// Current chatroom id.
    public private(set)var roomId = "" {
        willSet {
            if !newValue.isEmpty {
                ChatroomContext.shared?.roomId = newValue
            }
        }
    }
    
    /// Participants list request page number
    public private(set)var pageNum = 15
    
    public private(set) lazy var giftService: GiftService? = nil {
        willSet {
            newValue?.unbindGiftResponseListener(listener: self)
            if newValue != nil {
                newValue?.bindGiftResponseListener(listener: self)
            }
        }
    }
    
    public private(set) lazy var roomService: ChatroomService? = nil {
        willSet {
            newValue?.unbindResponse(response: self)
            if newValue != nil {
                newValue?.bindResponse(response: self)
            }
        }
    }
    
    public private(set) weak var chatDriver: IChatBarrageListDriver?
    
    public private(set) weak var giftDriver: IGiftsBarrageListDriver?
    
    public required init(roomId: String) {
        self.roomId = roomId
    }
    
    @objc public func bindChatDriver(driver: IChatBarrageListDriver) {
        self.chatDriver = driver
    }
    
    @objc public func bindGiftDriver(driver: IGiftsBarrageListDriver) {
        self.giftDriver = driver
    }
    
    @objc public func registerListener(listener: RoomEventsListener) {
        if self.eventsListener.contains(listener) {
            return
        }
        self.eventsListener.add(listener)
    }
    
    @objc public func unregisterListener(listener: RoomEventsListener) {
        if self.eventsListener.contains(listener) {
            self.eventsListener.remove(listener)
        }
    }
    
    private func handleError(type: RoomEventsError,error: ChatError) {
        for handler in self.eventsListener.allObjects {
            handler.onErrorOccur(error: error,type: type)
        }
    }
    
    //MARK: - Room operation
    @objc public func enterRoom(completion: @escaping (ChatError?) -> Void) {
        if let userId = ChatroomContext.shared?.currentUser?.userId  {
            self.roomService?.chatroomOperating(roomId: self.roomId, userId: userId, type: .join) { [weak self] success, error in
                guard let `self` = self else { return  }
                if !success {
                    consoleLogInfo("Joined chatroom error:\(error?.errorDescription ?? "")", type: .debug)
                    self.handleError(type: .join, error: error!)
                } else {
                    if self.roomService == nil {
                        self.roomService = ChatroomServiceImplement()
                    }
                    if self.giftService == nil {
                        self.giftService = GiftServiceImplement(roomId: self.roomId)
                    }
                }
                completion(error)
            }
        }
    }
    
    @objc public func leaveRoom(completion: @escaping (ChatError?) -> Void) {
        self.roomService?.chatroomOperating(roomId: self.roomId, userId: ChatClient.shared().currentUsername ?? "", type: .leave, completion: { [weak self] success, error in
            if success {
                self?.roomId = ""
            } else {
                self?.handleError(type: .leave, error: error!)
            }
        })
    }
    //MARK: - Participants operation
    @objc public func kick(userId: String,completion: @escaping (ChatError?) -> Void) {
        self.roomService?.operatingUser(roomId: self.roomId, userId: userId, type: .kick, completion: { [weak self] success, error in
            if error != nil {
                self?.handleError(type: .kick, error: error!)
            }
            completion(error)
        })
    }
    
    @objc public func mute(userId: String,completion: @escaping (ChatError?) -> Void) {
        self.roomService?.operatingUser(roomId: self.roomId, userId: userId, type: .mute, completion: { [weak self] success, error in
            if error != nil {
                self?.handleError(type: .mute, error: error!)
            }
            completion(error)
        })
    }
    
    @objc public func unmute(userId: String,completion: @escaping (ChatError?) -> Void) {
        self.roomService?.operatingUser(roomId: self.roomId, userId: userId, type: .mute, completion: { [weak self] success, error in
            if error != nil {
                self?.handleError(type: .unmute, error: error!)
            }
            completion(error)
        })
    }
    
//    @objc public func block(userId: String,completion: @escaping (ChatError?) -> Void) {
//        self.roomService?.operatingUser(roomId: self.roomId, userId: userId, type: .block, completion: { success, error in
//            completion(error)
//        })
//    }
//
//    @objc public func unblock(userId: String,completion: @escaping (ChatError?) -> Void) {
//        self.roomService?.operatingUser(roomId: self.roomId, userId: userId, type: .unblock, completion: { success, error in
//            completion(error)
//        })
//    }
//
//    @objc public func addAdmin(userId: String,completion: @escaping (ChatError?) -> Void) {
//        self.roomService?.operatingUser(roomId: self.roomId, userId: userId, type: .addAdministrator, completion: { success, error in
//            completion(error)
//        })
//    }
//
//    @objc public func removeAdmin(userId: String,completion: @escaping (ChatError?) -> Void) {
//        self.roomService?.operatingUser(roomId: self.roomId, userId: userId, type: .removeAdministrator, completion: { success, error in
//            completion(error)
//        })
//    }
    
    @objc public func translate(message: ChatMessage,completion: @escaping (ChatError?) -> Void) {
        self.roomService?.translateMessage(message: message, completion: { [weak self] translateResult, error in
            if error == nil,let translation = translateResult {
                self?.chatDriver?.refreshMessage(message: translation)
            } else {
                self?.handleError(type: .translate, error: error!)
            }
            completion(error)
        })
    }
    
    @objc public func recall(message: ChatMessage,completion: @escaping (ChatError?) -> Void) {
        self.roomService?.recall(messageId: message.messageId, completion: { [weak self] error in
            if error != nil {
                self?.handleError(type: .recall, error: error!)
            }
            completion(error)
        })
    }
    
    @objc public func report(message: ChatMessage,tag: String, reason: String,completion: @escaping (ChatError?) -> Void) {
        self.roomService?.report(messageId: message.messageId, tag: tag, reason: reason, completion: { [weak self] error in
            if error != nil {
                self?.handleError(type: .report, error: error!)
            }
            completion(error)
        })
    }
    
    @objc public func fetchParticipants(pageSize: UInt, completion: @escaping (([UserInfoProtocol]?,ChatError?)->Void)) {
        self.roomService?.fetchParticipants(roomId: self.roomId, pageSize: pageSize, completion: { [weak self] userIds, error in
            if let ids = userIds {
                var unknownUserIds = [String]()
                for userId in ids {
                    if ChatroomContext.shared?.usersMap?[userId] == nil {
                        unknownUserIds.append(userId)
                    }
                }
                if unknownUserIds.count > 0,RoomUIKitClient.shared.option.useProperties {
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
            } else {
                if error != nil {
                    self?.handleError(type: .fetchParticipants, error: error!)
                }
            }
        })
    }
    
    @objc public func fetchMuteUsers(pageSize: UInt, completion: @escaping (([UserInfoProtocol]?,ChatError?)->Void)) {
        self.roomService?.fetchMuteUsers(roomId: self.roomId, pageNum: UInt(self.pageNum), pageSize: pageSize, completion: { [weak self] userIds, error in
            if let ids = userIds {
                var unknownUserIds = [String]()
                for userId in ids {
                    if ChatroomContext.shared?.usersMap?[userId] == nil {
                        unknownUserIds.append(userId)
                    }
                }
                if unknownUserIds.count > 0,RoomUIKitClient.shared.option.useProperties {
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
            } else {
                if error != nil {
                    self?.handleError(type: .fetchMutes, error: error!)
                }
            }
        })
    }
}

extension RoomService: ChatroomResponseListener {
    
    public func onUserMuted(roomId: String, userId: String, operatorId: String) {
        for listener in self.eventsListener.allObjects {
            listener.onUserMuted(roomId: roomId, userId: userId, operatorId: operatorId)
        }

    }
    
    public func onUserUnmuted(roomId: String, userId: String, operatorId: String) {
        for listener in self.eventsListener.allObjects {
            listener.onUserUnmuted(roomId: roomId, userId: userId, operatorId: operatorId)
        }
    }
    
    public func onMessageRecalled(roomId: String, message: ChatMessage, by userId: String) {
        if roomId == self.roomId {
            self.chatDriver?.refreshMessage(message: message)
        }
    }
    
    public func onGlobalNotifyReceived(roomId: String, notifyMessage: ChatMessage) {
        for listener in self.eventsListener.allObjects {
            listener.onReceiveGlobalNotify(message: notifyMessage)
        }
    }
    
    public func onMessageReceived(roomId: String, message: ChatMessage) {
        if roomId == self.roomId {
            self.chatDriver?.showNewMessage(message: message)
        }
    }
        
    public func onUserJoined(roomId: String, user: UserInfoProtocol) {
        for listener in self.eventsListener.allObjects {
            listener.onUserJoined(roomId: roomId, user: user)
        }
    }
    
    public func onUserLeave(roomId: String, userId: String) {
        if roomId == self.roomId {
            ChatroomContext.shared?.usersMap?.removeValue(forKey: userId)
        }
    }
    
    public func onAnnouncementUpdate(roomId: String, announcement: String) {
        for listener in self.eventsListener.allObjects {
            listener.onAnnouncementUpdate(roomId: roomId, announcement: announcement)
        }
    }
    
    public func onUserBeKicked(roomId: String, reason: ChatroomBeKickedReason) {
        for listener in self.eventsListener.allObjects {
            listener.onUserBeKicked(roomId: roomId, reason: reason)
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

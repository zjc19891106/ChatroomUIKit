//
//  RoomService.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/8.
//

import UIKit

/// All of business service error
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
    
    /// You'll receive the callback on user left,
    /// - Parameters:
    ///   - roomId: chatroom id
    ///   - userId: user id
    func onUserLeave(roomId: String, userId: String)
    
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
    public private(set)var pageNum = 1
    
    public private(set) lazy var giftService: GiftService? = {
        let newValue = GiftServiceImplement(roomId: self.roomId)
        newValue.unbindGiftResponseListener(listener: self)
        newValue.bindGiftResponseListener(listener: self)
        return newValue
    }()
    
    public private(set) lazy var roomService: ChatroomService? =  {
        let implement = ChatroomServiceImplement()
        implement.unbindResponse(response: self)
        implement.bindResponse(response: self)
        return implement
    }()
    
    /// ``ChatroomView``  UI driver.
    public private(set) weak var chatDriver: IChatBarrageListDriver?
    
    /// ``GiftsBarrageList`` UI driver
    public private(set) weak var giftDriver: IGiftsBarrageListDriver?
    
    /// ``HorizontalTextCarousel`` UI driver
    public private(set) weak var notifyDriver: IHorizontalTextCarouselDriver?
    
    public required init(roomId: String) {
        self.roomId = roomId
    }
    
    func bindChatDriver(driver: IChatBarrageListDriver) {
        self.chatDriver = driver
    }
    
    func bindGiftDriver(driver: IGiftsBarrageListDriver) {
        self.giftDriver = driver
    }
    
    func bindGlobalNotifyDriver(driver: IHorizontalTextCarouselDriver) {
        self.notifyDriver = driver
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
    /// Switch to another chatroom.Notice,SDK'll clean users cache.Then fetch users&mute list.Will cause a lot of network io.Restricted to non-owner permissions.
    /// - Parameters:
    ///   - roomId: Chatroom id
    ///   - completion: switch result
    @objc public func switchChatroom(roomId: String,completion: @escaping (ChatError?) -> Void) {
        self.leaveRoom { _ in }
        self.roomId = roomId
        ChatroomContext.shared?.roomId = self.roomId
        ChatroomContext.shared?.usersMap?.removeAll()
        ChatroomContext.shared?.muteMap?.removeAll()
        self.enterRoom(completion: { [weak self] in
            if $0 == nil {
                self?.chatDriver?.cleanMessages()
            }
            completion($0)
        })
    }
    
    @objc public func enterRoom(completion: @escaping (ChatError?) -> Void) {
        if let userId = ChatroomContext.shared?.currentUser?.userId  {
            self.roomService?.chatroomOperating(roomId: self.roomId, userId: userId, type: .join) { [weak self] success, error in
                guard let `self` = self else { return  }
                if !success {
                    let errorInfo = "Joined chatroom error:\(error?.errorDescription ?? "")"
                    consoleLogInfo(errorInfo, type: .error)
                    self.handleError(type: .join, error: error!)
                    UIViewController.currentController?.makeToast(toast: errorInfo, duration: 3)
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
            } else {
                ChatroomContext.shared?.usersMap?.removeValue(forKey: userId)
            }
            completion(error)
        })
    }
    
    @objc public func mute(userId: String,completion: @escaping (ChatError?) -> Void) {
        self.roomService?.operatingUser(roomId: self.roomId, userId: userId, type: .mute, completion: { [weak self] success, error in
            if error != nil {
                self?.handleError(type: .mute, error: error!)
            } else {
                ChatroomContext.shared?.muteMap?[userId] = true
            }
            completion(error)
        })
    }
    
    @objc public func unmute(userId: String,completion: @escaping (ChatError?) -> Void) {
        self.roomService?.operatingUser(roomId: self.roomId, userId: userId, type: .mute, completion: { [weak self] success, error in
            if error != nil {
                self?.handleError(type: .unmute, error: error!)
            } else {
                ChatroomContext.shared?.muteMap?.removeValue(forKey: userId)
            }
            completion(error)
        })
    }
    
    @objc public func fetchParticipants(pageSize: UInt, completion: @escaping (([UserInfoProtocol]?,ChatError?)->Void)) {
        self.roomService?.fetchParticipants(roomId: self.roomId, pageSize: pageSize, completion: { [weak self] userIds, error in
            guard let `self` = self else { return  }
            if let ids = userIds {
                var unknownUserIds = [String]()
                for userId in ids {
                    if ChatroomContext.shared?.usersMap?[userId] == nil {
                        unknownUserIds.append(userId)
                    }
                }
                if ChatroomUIKitClient.shared.option.useProperties {
                    if unknownUserIds.count > 0,self.pageNum <= 1 {
                        ChatroomUIKitClient.shared.userImplement?.userInfos(userIds: unknownUserIds, completion: { infos, error in
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
                            }
                        }
                        completion(users,error)
                    }
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
                    self.handleError(type: .fetchParticipants, error: error!)
                }
            }
        })
    }
    
    @objc public func fetchMuteUsers(pageSize: UInt, completion: @escaping (([UserInfoProtocol]?,ChatError?)->Void)) {
        self.roomService?.fetchMuteUsers(roomId: self.roomId, pageNum: UInt(self.pageNum), pageSize: pageSize, completion: { [weak self] userIds, error in
            guard let `self` = self else { return }
            if let ids = userIds {
                var unknownUserIds = [String]()
                for userId in ids {
                    ChatroomContext.shared?.muteMap?[userId] = true
                    if ChatroomContext.shared?.usersMap?[userId] == nil {
                        unknownUserIds.append(userId)
                    }
                }
                if unknownUserIds.count > 0,self.pageNum == 1,ChatroomUIKitClient.shared.option.useProperties {
                    ChatroomUIKitClient.shared.userImplement?.userInfos(userIds: unknownUserIds, completion: { infos, error in
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
                    self.handleError(type: .fetchMutes, error: error!)
                }
            }
        })
    }
    
    /// Fetch user infos on members list end scroll,Then cache user info
    /// - Parameters:
    ///   - unknownUserIds: User ID array without user information
    ///   - completion: Callback user infos and error.
    @objc public func fetchThenCacheUserInfosOnEndScroll(unknownUserIds:[String], completion: @escaping (([UserInfoProtocol]?,ChatError?)->Void)) {
        ChatroomUIKitClient.shared.userImplement?.userInfos(userIds: unknownUserIds, completion: { infos, error in
            if error == nil {
                var users = [UserInfoProtocol]()
                for info in infos {
                    ChatroomContext.shared?.usersMap?[info.userId] = info
                }
                completion(users,error)
            } else {
                completion(nil,error)
            }
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
    //MARK: - Message operation
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
            } else {
                self?.chatDriver?.removeMessage(message: message)
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
            self.chatDriver?.removeMessage(message: message)
        }
    }
    
    public func onGlobalNotifyReceived(roomId: String, notifyMessage: ChatMessage) {
        if self.roomId == roomId {
            if let body = notifyMessage.body as? ChatTextMessageBody {
                self.notifyDriver?.showNewNotify(text: body.text)
            }
        }
        for listener in self.eventsListener.allObjects {
            listener.onReceiveGlobalNotify(message: notifyMessage)
        }
    }
    
    public func onMessageReceived(roomId: String, message: ChatMessage) {
        if roomId == self.roomId {
            self.chatDriver?.showNewMessage(message: message, gift: nil)
        }
    }
        
    public func onUserJoined(roomId: String, message: ChatMessage) {
        if roomId == self.roomId {
            self.chatDriver?.showNewMessage(message: message, gift: nil)
        }
        for listener in self.eventsListener.allObjects {
            if let user = message.user {
                listener.onUserJoined(roomId: roomId, user: user)
            }
        }
    }
    
    public func onUserLeave(roomId: String, userId: String) {
        for listener in self.eventsListener.allObjects {
            listener.onUserLeave(roomId: roomId, userId: userId)
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
        self.notifyDriver = nil
        self.roomId = ""
        ChatroomContext.shared?.roomId = nil
        ChatroomContext.shared?.usersMap?.removeAll()
        ChatroomContext.shared?.muteMap?.removeAll()
    }
}


extension RoomService: GiftResponseListener {
    
    public func receiveGift(gift: GiftEntityProtocol) {
        self.giftDriver?.receiveGift(gift: gift)
    }
    
    public func receiveGift(gift: GiftEntityProtocol, message: ChatMessage) {
        self.chatDriver?.showNewMessage(message: message,gift: gift)
    }
    
    
}

//
//  RoomUIKitClient.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/8.
//

import UIKit

/// A wrapper class for some options when initializing ChatroomUIKit.ChatroomView.
@objc open class RoomUIKitInitialOptions: NSObject {
    
    /// Is there a gift barrage?
    @objc public var hasGiftsBarrage = false
    
    /// ChatBottomBar data source.
    @objc public var bottomDataSource: [ChatBottomItemProtocol] = []
    
    /// Whether to hide the evoke keyboard button.
    @objc public var hiddenChatRaise = false
    
    /// Whether to use user attributes
    var useProperties: Bool = true
}

/// ChatroomUIKit initialize class.
@objcMembers final public class RoomUIKitClient: NSObject {
    
    static public let shared = RoomUIKitClient()
    
    /// User related protocol implementation class
    public private(set) lazy var userImplement: UserServiceProtocol? = nil
    
    /// Chat room related protocol implementation class
    public private(set) lazy var roomService: RoomService? = nil
    
    public private(set) lazy var option: RoomUIKitInitialOptions = RoomUIKitInitialOptions()
    
    public private(set) var roomId = ""
    
    /// Initialize chat room UIKit.
    /// - Parameter appKey: Application key.(https://docs.agora.io/en/agora-chat/get-started/enable?platform=ios)
    /// - Returns: Result error that nil  result indicates success, otherwise it fails.
    @objc public func setup(with appKey: String) -> ChatError? {
        ChatClient.shared().initializeSDK(with: Options(appkey: appKey))
    }
    
    /// Login method
    /// - Parameters:
    ///   - user: Conform UserInfoProtocol instance.
    ///   - token: Chat token
    ///   - userProperties: This parameter means whether the user passes in his or her own user information (including avatar, nickname, user id) as a user attribute for use in ChatRoomUIKit.
    ///   - completion: Login result.
    @objc public func login(with user: UserInfoProtocol,token: String,use userProperties: Bool = true,completion: @escaping (ChatError?) -> Void) {
        ChatroomContext.shared?.currentUser = user
        self.option.useProperties = userProperties
        self.userImplement = UserServiceImplement(userInfo: user, token: token, use: userProperties, completion: completion)
    }
    
    /// Login method
    /// - Parameters:
    ///   - userId: userId
    ///   - token: Chat token
    ///   - completion: Login result.
    @objc public func login(with userId: String,token: String,completion: @escaping (ChatError?) -> Void) {
        let user = User()
        user.userId = userId
        ChatroomContext.shared?.currentUser = user
        self.userImplement = UserServiceImplement(userInfo: user, token: token, use: false, completion: completion)
    }
    
    /// Launch a chatroom view of ChatroomUIKit.
    /// - Parameters:
    ///   - roomId: Chatroom id
    ///   - frame: Frame
    ///   - owner: Whether judge current user is owner or not.
    ///   - options: `RoomUIKitInitialOptions`
    /// - Returns: ChatroomUIKit.ChatroomView
    @objc public func launchRoomViewWithOptions(roomId: String,frame: CGRect, is owner: Bool, options: RoomUIKitInitialOptions = RoomUIKitInitialOptions()) -> ChatroomView {
        self.roomId = roomId
        ChatroomContext.shared?.owner = owner
        self.option.bottomDataSource = options.bottomDataSource
        self.option.hasGiftsBarrage = options.hasGiftsBarrage
        self.option.hiddenChatRaise = options.hiddenChatRaise
        let room = ChatroomView(frame: frame,bottom: options.bottomDataSource,showGiftBarrage: options.hasGiftsBarrage,hiddenChat: options.hiddenChatRaise)
        let service = RoomService(roomId: self.roomId)
        self.roomService = service
        room.connectService(service: service)
        return room
    }
    
    /// Register chatroom events listener
    /// - Parameter listener: RoomEventsListener
    @objc public func registerRoomEventsListener(listener: RoomEventsListener) {
        self.roomService?.registerListener(listener: listener)
    }
    
    /// Unregister chatroom events listener
    /// - Parameter listener: RoomEventsListener
    @objc public func unregisterRoomEventsListener(listener: RoomEventsListener) {
        self.roomService?.unregisterListener(listener: listener)
    }
    
    /// When you'll fetch new token from your app server on receive `RoomEventsListener.onUserTokenWillExpired`.
    /// - Parameter token: token
    @objc public func refreshToken(token: String) {
        ChatClient.shared().renewToken(token)
    }
}

extension RoomUIKitClient: UserStateChangedListener {
    
    public func onUserLoginOtherDevice(device: String) {
        //User will be kick by UIKit.
        if let service = self.roomService {
            for listener in service.eventsListener.allObjects {
                listener.onUserLoginOtherDevice(device: device)
            }
        }
    }
    
    public func onUserTokenWillExpired() {
        //Renew token form your service
        if let service = self.roomService {
            for listener in service.eventsListener.allObjects {
                listener.onUserTokenWillExpired()
            }
        }
    }
    
    public func onUserTokenDidExpired() {
        //Renew token form your service
        if let service = self.roomService {
            for listener in service.eventsListener.allObjects {
                listener.onUserTokenDidExpired()
            }
        }
    }
    
    public func onSocketConnectionStateChanged(state: ConnectionState) {
        switch state {
        case .connected:
            if !self.roomId.isEmpty {
                self.roomService?.enterRoom(completion: { _ in
                    
                })
            }
        default:
            break
        }
        if let service = self.roomService {
            for listener in service.eventsListener.allObjects {
                listener.onSocketConnectionStateChanged(state: state)
            }
        }

    }
    
    
}

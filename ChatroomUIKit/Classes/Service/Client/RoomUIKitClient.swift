//
//  RoomUIKitClient.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/8.
//

import UIKit

@objc open class RoomUIKitInitialOptions: NSObject {
    @objc public var hasGiftsBarrage = false
    
    @objc public var bottomDataSource: [ChatBottomItemProtocol] = []
    
    @objc public var hiddenChatRaise = false
}

@objc final public class RoomUIKitClient: NSObject {
    
    static public let shared = RoomUIKitClient()
    
    lazy var userImplement: UserServiceProtocol? = nil
    
    public var roomService: RoomService?
    
    var roomId = ""
    
    var useProperties: Bool = true
    
    /// Description Initialize chat room UIKit.
    /// - Parameter appKey: Application key.(https://docs.agora.io/en/agora-chat/get-started/enable?platform=ios)
    /// - Returns: Result error that nil  result indicates success, otherwise it fails.
    @objc public func setup(with appKey: String) -> ChatError? {
        ChatClient.shared().initializeSDK(with: Options(appkey: appKey))
    }
    
    /// Description Login method
    /// - Parameters:
    ///   - user: Conform UserInfoProtocol instance.
    ///   - token: Chat token
    ///   - userProperties: This parameter means whether the user passes in his or her own user information (including avatar, nickname, user id) as a user attribute for use in ChatRoomUIKit.
    ///   - completion: Login result.
    @objc public func login(with user: UserInfoProtocol,token: String,use userProperties: Bool = true,completion: @escaping (ChatError?) -> Void) {
        self.useProperties = userProperties
        ChatroomContext.shared?.currentUser = user
        self.userImplement = UserServiceImplement(userInfo: user, token: token, use: userProperties, completion: completion)
    }
    
    @objc public func login(with userId: String,token: String,completion: @escaping (ChatError?) -> Void) {
        let user = User()
        user.userId = userId
        ChatroomContext.shared?.currentUser = user
        self.userImplement = UserServiceImplement(userInfo: user, token: token, use: false, completion: completion)
    }
    
    @objc public func launchRoomView(roomId: String,frame: CGRect) -> ChatroomView {
        self.roomId = roomId
        let room = ChatroomView(frame: frame)
        let service = RoomService(roomId: self.roomId)
        room.connectService(service: service)
        self.roomService = service
        return room
    }
    
    @objc public func launchRoomViewWithOptions(roomId: String,frame: CGRect,options: RoomUIKitInitialOptions) -> ChatroomView {
        self.roomId = roomId
        let room = ChatroomView(frame: frame,bottom: options.bottomDataSource,showGiftBarrage: options.hasGiftsBarrage,hiddenChat: options.hiddenChatRaise)
        let service = RoomService(roomId: self.roomId)
        self.roomService = service
        room.connectService(service: service)
        return room
    }
    
    @objc public func registerRoomResponseListener() {
//        self.roomService.
    }
    
    @objc public func registerRoomRequestListener() {
        
    }
}

extension RoomUIKitClient: UserStateChangedListener {
    public func onUserLoginOtherDevice(device: String) {
        //User will be kick by UIKit.
    }
    
    public func onUserTokenDidExpired() {
        //Renew token form your service
    }
    
    public func onSocketConnectionStateChanged(state: ConnectionState) {
        
    }
    
    
}

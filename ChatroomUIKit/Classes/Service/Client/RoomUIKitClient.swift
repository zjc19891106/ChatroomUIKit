//
//  RoomUIKitClient.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/8.
//

import UIKit

final public class RoomUIKitClient: NSObject {
    
    static public let shared = RoomUIKitClient()
    
    lazy var userImplement: UserServiceProtocol? = nil
    
    /// Description Initialize chat room UIKit.
    /// - Parameter appKey: Application key.(https://docs.agora.io/en/agora-chat/get-started/enable?platform=ios)
    /// - Returns: Result error that nil  result indicates success, otherwise it fails.
    public func setup(with appKey: String) -> ChatError? {
        ChatClient.shared().initializeSDK(with: Options(appkey: appKey))
    }
    
    /// Description Login method
    /// - Parameters:
    ///   - user: Conform UserInfoProtocol instance.
    ///   - token: Chat token
    ///   - userProperties: This parameter means whether the user passes in his or her own user information (including avatar, nickname, user id) as a user attribute for use in ChatRoomUIKit.
    ///   - completion: Login result.
    public func login(with user: UserInfoProtocol,token: String,use userProperties: Bool = true,completion: @escaping (ChatError?) -> Void) {
        ChatroomContext.shared?.currentUser = user
        self.userImplement = UserServiceImplement(userInfo: user, token: token, use: userProperties, completion: completion)
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

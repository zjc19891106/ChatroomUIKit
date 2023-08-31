//
//  UserServiceImplement.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/8/30.
//

import UIKit
import HyphenateChat
import KakaJSON

@objc public final class UserServiceImplement: NSObject {
        
    private var responseDelegates: NSHashTable<UserStateChangedListener> = NSHashTable<UserStateChangedListener>.weakObjects()
    
    init(userInfo: UserInfoProtocol,token: String,use userProperty: Bool) {
        ChatroomContext.shared?.currentUser = userInfo
        super.init()
        self.login(userId: userInfo.userId, token: token) { [weak self] success, error in
            if !success {
                consoleLogInfo(error?.errorDescription ?? "", type: .debug)
            } else {
                self?.updateUserInfo(userInfo: userInfo, completion: { success, error in
                    if !success {
                        consoleLogInfo("update user info failure:\(error?.errorDescription ?? "")", type: .debug)
                    }
                })
            }
        }
    }
    
    deinit {
        consoleLogInfo("\(self.chatroom.swiftClassName ?? "") deinit", type: .debug)
    }

}

extension UserServiceImplement:UserServiceProtocol {
    
    public func bindUserStateChangedListener(listener: UserStateChangedListener) {
        if self.responseDelegates.contains(listener) {
            return
        }
        self.responseDelegates.add(listener)
    }
    
    public func unBindUserStateChangedListener(listener: UserStateChangedListener) {
        if self.responseDelegates.contains(listener) {
            self.responseDelegates.remove(listener)
        }
    }
    
    public func userInfo(userId: String, completion: @escaping (UserInfoProtocol?,ChatError?) -> Void) {
        self.userInfos(userIds: [userId]) { infos,error in
            completion(infos.first,error)
        }
    }
    
    public func userInfos(userIds: [String], completion: @escaping ([UserInfoProtocol],ChatError?) -> Void) {
        EMClient.shared().userInfoManager?.fetchUserInfo(byId: userIds,completion: { [weak self] infoMap, error in
            guard let dic = infoMap as? Dictionary<String,EMUserInfo> else { return }
            var users = [User]()
            for userId in userIds {
                if let info = dic[userId] {
                    if let user = self?.convertToUser(info: info) {
                        users.append(user)
                    }
                }
            }
            completion(users,error)
        })
    }
    
    public func updateUserInfo(userInfo: UserInfoProtocol, completion: @escaping (Bool, ChatError?) -> Void) {
        EMClient.shared().userInfoManager?.updateOwn(self.convertToUserInfo(user: userInfo),completion: { user, error in
            completion(error == nil,error)
        })
    }
    
    public func login(userId: String, token: String, completion: @escaping (Bool, ChatError?) -> Void) {
        EMClient.shared().login(withUsername: userId, token: token) { user_id, error in
            completion(error == nil,error)
        }
    }
    
    public func logout(completion: @escaping (Bool, ChatError?) -> Void) {
        EMClient.shared().logout(false)
    }
    
    private func convertToUser(info: EMUserInfo) -> User {
        let user = User()
        user.userId = info.userId ?? ""
        user.nickName = info.nickname ?? ""
        user.avatarURL = info.avatarUrl ?? ""
        user.gender = info.gender
        return user
    }
    
    private func convertToUserInfo(user: UserInfoProtocol) -> EMUserInfo {
        let info = EMUserInfo()
        info.userId = user.userId
        info.nickname = user.nickName
        info.avatarUrl = user.avatarURL
        info.gender = user.gender
        return info
    }
    
}

//MARK: - EMClientDelegate
extension UserServiceImplement: EMClientDelegate {
    public func tokenDidExpire(_ aErrorCode: ChatErrorCode) {
        for response in self.responseDelegates.allObjects {
            response.onUserTokenDidExpired()
        }
    }
    
    public func userAccountDidLogin(fromOtherDevice aDeviceName: String?) {
        for response in self.responseDelegates.allObjects {
            if let device = aDeviceName {
                response.onUserLoginOtherDevice(device: device)
            }
        }
    }
}

@objcMembers final public class User:NSObject, UserInfoProtocol,Convertible {
    
    public var userId: String = ""
    
    public var nickName: String = ""
    
    public var avatarURL: String = ""
    
    public var gender: Int = 1
    
    override public required init() {}
    
    public func kj_modelKey(from property: Property) -> ModelPropertyKey {
        property.name
    }
}

extension EMUserInfo: Convertible {
    
}

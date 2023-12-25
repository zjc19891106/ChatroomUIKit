//
//  Configer.swift
//  ChatroomUIKit_Example
//
//  Created by 朱继超 on 2023/9/15.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import ChatroomUIKit
/*
 First,you can create application and open chat function on `https://docs.agora.io/en/agora-chat/get-started/enable?platform=ios` website.Then enable chat function.
 
 Second,generate temporary token for test.
 **/
public class ExampleRequiredConfig {
    // https://docs.agora.io/en/agora-chat/get-started/enable?platform=ios
    static let appKey: String = <#Agora Chat Appkey#>
    //  ProjectManager->Operation Manager->User->Create User.Then Basic Information->Application Info->Chat User temp token.Next,fill below param.Move on,fill user id.
    static var chatToken: String = <#Agora Chat Token#>
    //    Follow the following process to create a chat room on console.
    //    ProjectManager->Operation Manager->Chat Room->Create Chat Room.Then fill in the `chatroomId` parameter below.
    
    /// `YourAppUser` means that you application project's user class.
    public final class YourAppUser: NSObject,UserInfoProtocol {
        public var identity: String = ""//user level picture url
        
        public func toJsonObject() -> Dictionary<String, Any>? {
            ["userId":self.userId,"nickName":self.nickname,"avatarURL":self.avatarURL,"identity":self.identity,"gender":self.gender]
        }
        
        
        public var userId: String = <#Agora Chat User ID#>
        
        public var nickname: String = "Jack"
        
        public var avatarURL: String = "https://accktvpic.oss-cn-beijing.aliyuncs.com/pic/sample_avatar/sample_avatar_1.png"
        
        public var gender: Int = 1
        
        
        
    }
}

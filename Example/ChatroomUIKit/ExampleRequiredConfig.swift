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
    static let appKey: String = "1182230915209398#chatroomuikit-test"
    //  ProjectManager->Operation Manager->User->Create User.Then Basic Information->Application Info->Chat User temp token.Next,fill below param.Move on,fill user id.
    static let chatToken: String = "YWMtxgbdola8Ee6UGq1IimamaZGgQVxu0koxi-vGtfdnugRF312QU4sR7p1bEc5SYULxAwMAAAGKrE5MVDeeSAB1UEl0Bc9XdBkrsYRzBt9H-88RwQgDZyJc6YEmtvbSlg"
    //    Follow the following process to create a chat room on console.
    //    ProjectManager->Operation Manager->Chat Room->Create Chat Room.Then fill in the `chatroomId` parameter below.
    
    /// `YourAppUser` means that you application project's user class.
    public final class YourAppUser: NSObject,UserInfoProtocol {
        
        public var userId: String = "18811508760"
        
        public var nickName: String = "Jack"
        
        public var avatarURL: String = "https://accktvpic.oss-cn-beijing.aliyuncs.com/pic/sample_avatar/sample_avatar_1.png"
        
        public var gender: Int = 1
        
        public var identify: String = "https://accktvpic.oss-cn-beijing.aliyuncs.com/pic/sample_avatar/sample_avatar_2.png"
        
        
    }
}

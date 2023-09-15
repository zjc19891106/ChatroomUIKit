//
//  Configer.swift
//  ChatroomUIKit_Example
//
//  Created by 朱继超 on 2023/9/15.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
/*
 First,you can create application and open chat function on `https://console.agora.io/project/WLRRH-ir6/extension?id=Chat` website.Then fill in the appKey parameter below.
 
 Second,generate temporary token for test.
 **/
struct ChatroomUIKitConfig {
    //https://docs.agora.io/en/agora-chat/restful-api/chatroom-management/manage-chatrooms?platform=ios
    //https://console.agora.io/project/WLRRH-ir6/extension?id=Chat
    static let generateTemporaryTokenURL = "https://console.easemob.com/app/applicationOverview/userManagement"
    
    static let appKey: String = "1182230915209398#chatroomuikit-test"
    
    static let chatToken = "YWMtSq1EaFOLEe6GyjlzKjsLlJGgQVxu0koxi-vGtfdnugRF312QU4sR7p1bEc5SYULxAwMAAAGKl2DZZTeeSACGFzMmVyZQbBMuJBdU7gxkduqjhqwcV-03CI_FJ-Q4CA"
    
    static let chatroomId = "225823312379909"
}

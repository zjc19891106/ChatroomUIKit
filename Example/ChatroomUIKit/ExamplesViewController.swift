//
//  ExamplesViewController.swift
//  ChatroomUIKit_Example
//
//  Created by 朱继超 on 2023/9/15.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import ChatroomUIKit

final class ExamplesViewController: UIViewController {

    @IBOutlet weak var component_UI: UIButton!
    
    @IBOutlet weak var business_UI: UIButton!
    
    @IBOutlet weak var component_UI_OC: UIButton!
    
    @IBOutlet weak var business_UI_OC: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ChatroomUIKit Examples"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func push_component_UI(_ sender: UIButton) {
        self.navigationController?.pushViewController(UIComponentsExampleViewController(), animated: true)
    }
    /*
     Follow the following process to create a chat room on console.
     ProjectManager->Operation Manager->Chat Room->Create Chat Room.Then fill in the `chatroomId` parameter below.
     **/
    @IBAction func push_business_UI(_ sender: Any) {
        // You can visit`ChatroomUIKitConfig.generateTemporaryTokenURL` website.Create application then generate temporary token.
        ChatroomUIKitClient.shared.login(with: YourAppUser(), token: ChatroomUIKitConfig.chatToken, use: true) { error in
            if error == nil || error?.code == .errorUserAlreadyLoginSame {
                self.navigationController?.pushViewController(UIWithBusinessViewController(chatroomId: ChatroomUIKitConfig.chatroomId), animated: true)
            } else {
                consoleLogInfo("ChatroomUIKitClient login failed!\nError:\(error?.errorDescription ?? "")", type: .debug)
            }
        }
    }
    
    @IBAction func push_OC_UI_component(_ sender: Any) {
        self.navigationController?.pushViewController(OCUIComponentsExampleViewController(), animated: true)
    }
    @IBAction func push_OC_Business_UI(_ sender: UIButton) {
        // You can visit`ChatroomUIKitConfig.generateTemporaryTokenURL` website.Create application then generate temporary token.
        ChatroomUIKitClient.shared.login(with: YourAppUser(), token: ChatroomUIKitConfig.chatToken, use: true) { error in
            if error == nil {
                self.navigationController?.pushViewController(OCBusinessUIViewController(), animated: true)
            } else {
                consoleLogInfo("ChatroomUIKitClient login failed!\nError:\(error?.errorDescription ?? "")", type: .debug)
            }
        }
    }
    
    deinit {
        ChatroomUIKitClient.shared.logout()
    }
}

final class YourAppUser: NSObject,UserInfoProtocol {
    
    var userId: String = "18811508760"
    
    var nickName: String = "Jack"
    
    var avatarURL: String = "https://accktvpic.oss-cn-beijing.aliyuncs.com/pic/sample_avatar/sample_avatar_1.png"
    
    var gender: Int = 1
    
    var identify: String = "https://accktvpic.oss-cn-beijing.aliyuncs.com/pic/sample_avatar/sample_avatar_2.png"
    
    
}


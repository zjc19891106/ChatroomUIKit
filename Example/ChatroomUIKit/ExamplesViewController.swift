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

    @IBAction func push_business_UI(_ sender: Any) {
        ChatroomUIKitClient.shared.login(with: ExampleRequiredConfig.YourAppUser(), token: ExampleRequiredConfig.chatToken, use: true) { error in
            if error == nil || error?.code == .errorUserAlreadyLoginSame {
                self.navigationController?.pushViewController(ChatroomListViewController(), animated: true)
            } else {
                consoleLogInfo("ChatroomUIKitClient login failed!\nError:\(error?.errorDescription ?? "")", type: .debug)
            }
        }
    }
    
    @IBAction func push_OC_UI_component(_ sender: Any) {
        self.navigationController?.pushViewController(OCUIComponentsExampleViewController(), animated: true)
    }
    @IBAction func push_OC_Business_UI(_ sender: UIButton) {
        ChatroomUIKitClient.shared.login(with: ExampleRequiredConfig.YourAppUser(), token: ExampleRequiredConfig.chatToken, use: true) { error in
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




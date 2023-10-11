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
    
    @IBOutlet weak var userNameField: UITextField!
    
    @IBOutlet weak var chatTokenField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ChatroomUIKit Examples"
        // Do any additional setup after loading the view.
        self.userNameField.delegate = self
        self.chatTokenField.delegate = self
    }
    
    @IBAction func push_component_UI(_ sender: UIButton) {
        self.navigationController?.pushViewController(UIComponentsExampleViewController(), animated: true)
    }

    @IBAction func push_business_UI(_ sender: Any) {
        let user = ExampleRequiredConfig.YourAppUser()
        if let userName = self.userNameField.text,!userName.isEmpty {
            user.userId = userName
        }
        ChatroomUIKitClient.shared.login(with: user, token: ExampleRequiredConfig.chatToken, use: true) { error in
            if error == nil || error?.code == .errorUserAlreadyLoginSame {
                self.navigationController?.pushViewController(ChatroomListViewController(), animated: true)
            } else {
                let errorInfo = "ChatroomUIKitClient login failed!\nError:\(error?.errorDescription ?? "")"
                consoleLogInfo(errorInfo, type: .error)
                UIViewController.currentController?.makeToast(toast: errorInfo, duration: 3)
            }
        }
    }
    
    @IBAction func push_OC_UI_component(_ sender: Any) {
        self.navigationController?.pushViewController(OCUIComponentsExampleViewController(), animated: true)
    }
    
}

extension ExamplesViewController: UITextFieldDelegate  {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 11 {
            if let text = textField.text {
                ExampleRequiredConfig.chatToken = text
            }
        }
    }
}

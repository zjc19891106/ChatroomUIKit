//
//  ViewController.swift
//  ChatroomUIKit
//
//  Created by zjc19891106 on 08/30/2023.
//  Copyright (c) 2023 zjc19891106. All rights reserved.
//

import UIKit
import ChatroomUIKit


final class ExampleViewController: UIViewController {

    lazy var actionSheet: ActionSheet = {
        let items = [ActionSheetItem(title: "Operation", type: .normal, action: { item in
            
        }),ActionSheetItem(title: "Delete", type: .destructive, action: { item in
            
        })]
        return ActionSheet(items: items,title: "Title",message: nil)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.backgroundColor = UIColor.theme.primaryColor0
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        button.backgroundColor = .orange
        button.addTarget(self, action: #selector(showMenu(sender:)), for: .touchUpInside)
        self.view.addSubview(button)
//        UIImage(named: "", in: .main, with: .none)
        let theme = UIButton(type: .custom)
        theme.frame = CGRect(x: 100, y: 300, width: 100, height: 100)
        theme.backgroundColor = .red
        theme.addTarget(self, action: #selector(switchTheme), for: .touchUpInside)
        self.view.addSubview(theme)
        
        let imageView = UIImageView(frame: CGRect(x: 100, y: 400, width: 100, height: 100)).backgroundColor(.white)
        self.view.addSubview(imageView)
//        let chat = ChatRoomView(frame: .zero)
//        chat.bindService(service: ChatroomUIKitService(roomId: "", token: "", user: CustomInfo()))
//        self.view.addSubview(chat)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 100
        let text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit asdasdasdasdasdasdasdasd."
        let attributedText = NSAttributedString(string: text, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        let label = UILabel(frame: CGRect(x: 20, y: 400, width: ScreenWidth-120, height: 100)).backgroundColor(.gray)
        label.attributedText = attributedText
        label.numberOfLines = 0
        self.view.addSubview(label)
        let input = ChatInputBar(frame: CGRect(x: 0, y: ScreenHeight-62, width: ScreenWidth, height: 52),text: nil,placeHolder: "Please")
        self.view.addSubview(input)
        
    }
    
    @objc func switchTheme() {
        Theme.switchTheme(style: .dark)
//        Theme.switchHues(hues: [0.56,0.66,0.76,0.56,0.54])
    }
   
    // 长按手势处理方法
    @objc func showMenu(sender: UIButton) {
        self.view.addSubview(self.actionSheet)
        
//        let alert = UIAlertController(title: "title", message: "message asdasdsad asdasdasdasdasdasdasdasdasdasdasdasdasdasd", preferredStyle: .actionSheet)
//        alert.addAction(UIAlertAction(title: "Delete", style: .destructive))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        self.present(alert, animated: true)
    }

}


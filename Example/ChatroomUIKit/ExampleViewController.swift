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
        ActionSheet(items: [ActionSheetItem(title: "Operation", type: .normal),ActionSheetItem(title: "Delete", type: .destructive)],title: "Title",message: nil)
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
//        self.view.addSubview(label)
        let input = ChatInputBar(frame: CGRect(x: 0, y: ScreenHeight-62, width: ScreenWidth, height: 52),text: nil,placeHolder: "Please")
        self.view.addSubview(input)
//        self.view.createGradient(GradientColors.gradientColors0, GradientForwardPoints.bottomLeftToTopRight, [NSNumber(value: 0),NSNumber(value: 1)])
    }
    
    @objc func switchTheme() {
        Theme.switchTheme(style: .dark)
//        Theme.switchHues()
    }
   
    // 长按手势处理方法
    @objc func showMenu(sender: UIButton) {
        self.actionSheet.items[safe: 0]?.action = { [weak self] item in
            
        }
        self.view.addSubview(self.actionSheet)
        
//        let alert = UIAlertController(title: "title", message: "message asdasdsad asdasdasdasdasdasdasdasdasdasdasdasdasdasd", preferredStyle: .actionSheet)
//        alert.addAction(UIAlertAction(title: "Delete", style: .destructive))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        self.present(alert, animated: true)
    }

}


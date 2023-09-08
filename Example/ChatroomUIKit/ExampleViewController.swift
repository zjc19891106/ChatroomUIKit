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
    
    lazy var background: UIImageView = {
        UIImageView(frame: self.view.frame).image(UIImage(named: "bg_img_of_dark_mode"))
    }()

    lazy var actionSheet: ActionSheet = {
        ActionSheet(items: [ActionSheetItem(title: "Operation", type: .normal),ActionSheetItem(title: "Delete", type: .destructive)],title: "Title",message: nil)
    }()
    
    lazy var giftBarrages: GiftsBarrageList = {
        GiftsBarrageList(frame: CGRect(x: 10, y: 400, width: self.view.frame.width-100, height: ScreenWidth / 9.0 * 2.5),source:nil)
    }()
    
    lazy var barrageList: ChatBarrageList = {
        ChatBarrageList(frame: CGRect(x: 0, y: 500, width: self.view.frame.width-50, height: 200))
    }()
    
    lazy var bottomBar: ChatBottomFunctionBar = {
        ChatBottomFunctionBar(frame: CGRect(x: 0, y: self.view.frame.height-54-BottomBarHeight, width: self.view.frame.width, height: 54), datas: self.bottomBarDatas(), hiddenChat: false)
    }()
    
    lazy var inputBar: ChatInputBar = {
        ChatInputBar(frame: CGRect(x: 0, y: ScreenHeight, width: ScreenWidth, height: 52),text: nil,placeHolder: "Input words.")
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        let user = User()
        user.nickName = "Jack"
        user.avatarURL = "https://accktvpic.oss-cn-beijing.aliyuncs.com/pic/sample_avatar/sample_avatar_1.png"
        user.identify = "https://accktvpic.oss-cn-beijing.aliyuncs.com/pic/sample_avatar/sample_avatar_2.png"
        user.userId = "12323123123"
        ChatroomContext.shared?.currentUser = user
        self.view.addSubview(self.background)
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
//        let chat = ChatRoomView(frame: .zero)
//        chat.bindService(service: ChatroomUIKitService(roomId: "", token: "", user: CustomInfo()))
//        self.view.addSubview(chat)
        self.view.addSubview(self.giftBarrages)
        self.view.addSubview(self.barrageList)
        self.view.addSubview(self.bottomBar)
        self.view.addSubview(self.inputBar)
//        self.view.createGradient(GradientColors.gradientColors0, GradientForwardPoints.bottomLeftToTopRight, [NSNumber(value: 0),NSNumber(value: 1)])
        self.bottomBar.raiseKeyboard = { [weak self] in
            self?.inputBar.show()
        }
        self.inputBar.sendClosure = { [weak self] in
            guard let `self` = self else { return }
            self.barrageList.showNewMessage(entity: self.startMessage($0))
        }
        
        self.bottomBar.actionClosure = { [weak self] in
            switch $0.type {
            case 2:
                DialogManager.shared.showGiftsDialog(gifts: self?.gifts() ?? []) { item in
                    item.sendUser = ChatroomContext.shared?.currentUser
                    item.giftCount = "1"
                    self?.giftBarrages.gifts.append(item)
                }
            default:
                break
            }
        }
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
        
    }
    
    func bottomBarDatas() -> [ChatBottomItemProtocol] {
        var entities = [ChatBottomItemProtocol]()
        let names = ["ellipsis.circle","mic.slash","gift"]
        for i in 0...names.count-1 {
            let entity = ChatBottomItem()
            entity.showRedDot = false
            entity.selected = false
            entity.selectedImage = UIImage(systemName: names[i])?.withTintColor(UIColor.theme.neutralColor98,renderingMode: .alwaysOriginal)
            entity.normalImage = UIImage(systemName: names[i])?.withTintColor(UIColor.theme.neutralColor98,renderingMode: .alwaysOriginal)
            entity.type = i
            entities.append(entity)
        }
        return entities
    }
    
    @objc func startMessage(_ text: String?) -> ChatEntity {
        let entity = ChatEntity()
        let user = ChatroomContext.shared?.currentUser as? User
        entity.message = ChatMessage(conversationID: "test", from: "12323123123", to: "test",body: ChatTextMessageBody(text: text == nil ? "Welcome":text), ext: user?.kj.JSONObject())
        entity.attributeText = entity.attributeText
        entity.width = entity.width
        entity.height = entity.height
        return entity
    }

    private func gifts() -> [GiftEntityProtocol] {
        if let path = Bundle.main.url(forResource: "Gifts", withExtension: "json") {
            var data = Dictionary<String,Any>()
            do {
                data = try Data(contentsOf: path).chatroom.toDictionary() ?? [:]
            } catch {
                assert(false)
            }
            if let jsons = data["gifts"] as? [Dictionary<String,Any>] {
                return jsons.kj.modelArray(GiftEntity.self)
            }
        }
        return []
    }
}

class ChatBottomItem:NSObject, ChatBottomItemProtocol {
    var showRedDot: Bool = false
    
    var selected: Bool = false
    
    var selectedImage: UIImage?
    
    var normalImage: UIImage?
    
    var type: Int = 0
   
    
}

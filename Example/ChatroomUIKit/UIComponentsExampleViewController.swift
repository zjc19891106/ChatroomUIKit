//
//  ViewController.swift
//  ChatroomUIKit
//
//  Created by zjc19891106 on 08/30/2023.
//  Copyright (c) 2023 zjc19891106. All rights reserved.
//

import UIKit
import ChatroomUIKit

final class UIComponentsExampleViewController: UIViewController {
    
    lazy var background: UIImageView = {
        UIImageView(frame: self.view.frame).image(UIImage(named: "bg_img_of_dark_mode"))
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
    
    lazy var gift1: GiftsViewController = {
        GiftsViewController(gifts: self.gifts(), result: self)
    }()
    
    lazy var gift2: GiftsViewController = {
        GiftsViewController(gifts: self.gifts(), result: self)
    }()
    
    lazy var carouselTextView: HorizontalTextCarousel = {
        HorizontalTextCarousel(originPoint: CGPoint(x: 20, y: 60), width: self.view.frame.width-40, font: .systemFont(ofSize: 20, weight: .semibold), textColor: UIColor.theme.neutralColor98).cornerRadius(.large)
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
        self.view.addSubview(self.giftBarrages)
        self.view.addSubview(self.barrageList)
        self.view.addSubview(self.bottomBar)
        self.view.addSubview(self.inputBar)
        
        self.bottomBar.addActionHandler(actionHandler: self)
        self.inputBar.sendClosure = { [weak self] in
            guard let `self` = self else { return }
            self.barrageList.showNewMessage(message: self.startMessage($0))
        }

        let button = UIButton(type: .custom).frame(CGRect(x: 100, y: 120, width: 150, height: 20)).textColor(.white, .normal).backgroundColor(UIColor.theme.primaryColor6).cornerRadius(.extraSmall).title("Add Global Notify", .normal).addTargetFor(self, action: #selector(addCarouselTask), for: .touchUpInside)
        self.view.addSubview(button)
        self.view.addSubview(self.carouselTextView)
        
        self.carouselTextView.alpha = 0
        
        let switchTheme = UIButton(type: .custom).frame(CGRect(x: 100, y: 160, width: 150, height: 20)).textColor(.white, .normal).backgroundColor(UIColor.theme.primaryColor6).cornerRadius(.extraSmall).title("Switch Theme", .normal).addTargetFor(self, action: #selector(switchTheme), for: .touchUpInside)
        self.view.addSubview(switchTheme)
        
        self.carouselTextView.alpha = 0
        
    }

    
}


extension UIComponentsExampleViewController: GiftToChannelResultDelegate {
    
    func giftResult(gift: ChatroomUIKit.GiftEntityProtocol, error: ChatroomUIKit.ChatError?) {
        print("user can report to service.")
    }
}

extension UIComponentsExampleViewController: ChatBottomFunctionBarActionEvents {
    func onBottomItemClicked(item: ChatroomUIKit.ChatBottomItemProtocol) {
        switch item.type {
        case 2:
            DialogManager.shared.showGiftsDialog(titles: ["Gifts","1231232"], gifts: [self.gift1,self.gift2])
        default:
            break
        }
    }
    
    func onKeyboardWillWakeup() {
        self.inputBar.show()
    }
    
    
}

extension UIComponentsExampleViewController {
    
    @objc func addCarouselTask() {
        self.carouselTextView.addTask(text: ["123123adadsasjdaklsdjaskldjakdjakldsjkadjkasldjalksjdlkjasdklsajdl","99999999999999999999999999999999","66666666666666666666666666666"].randomElement()!)
    }
    
    @objc func switchTheme() {
        Theme.switchTheme(style: .dark)
//        Theme.switchHues()
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
    
    @objc func startMessage(_ text: String?) -> ChatMessage {
        let user = ChatroomContext.shared?.currentUser as? User
        return ChatMessage(conversationID: "test", from: "12323123123", to: "test",body: ChatTextMessageBody(text: text == nil ? "Welcome":text), ext: user?.kj.JSONObject())
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
    
    var action: ((ChatroomUIKit.ChatBottomItemProtocol) -> Void)?
    
    var showRedDot: Bool = false
    
    var selected: Bool = false
    
    var selectedImage: UIImage?
    
    var normalImage: UIImage?
    
    var type: Int = 0
   
}



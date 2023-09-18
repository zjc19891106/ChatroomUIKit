//
//  UIWithBusinessViewController.swift
//  ChatroomUIKit_Example
//
//  Created by 朱继超 on 2023/9/15.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import ChatroomUIKit

final class UIWithBusinessViewController: UIViewController {
    
    var roomId = ""
    
    var option: ChatroomUIKitInitialOptions {
        let options  = ChatroomUIKitInitialOptions()
        options.bottomDataSource = self.bottomBarDatas()
        options.hasGiftsBarrage = true
        options.hiddenChatRaise = false
        return options
    }
    
    lazy var background: UIImageView = {
        UIImageView(frame: self.view.frame).image(UIImage(named: "bg_img_of_dark_mode"))
    }()
    
    lazy var roomView: ChatroomUIKit.ChatroomView = {
        ChatroomUIKitClient.shared.launchRoomViewWithOptions(roomId: self.roomId, frame: CGRect(x: 0, y: ScreenHeight/2.0, width: ScreenWidth, height: ScreenHeight/2.0), is: true, options: self.option)
    }()
    
    lazy var carouselTextView: HorizontalTextCarousel = {
        HorizontalTextCarousel(originPoint: CGPoint(x: 20, y: 100), width: self.view.frame.width-40, font: .systemFont(ofSize: 20, weight: .semibold), textColor: UIColor.theme.neutralColor98).cornerRadius(.large)
    }()
    
    lazy var members: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 100, y: 160, width: 150, height: 20)).textColor(.white, .normal).backgroundColor(UIColor.theme.primaryColor6).cornerRadius(.extraSmall).title("Participants", .normal).addTargetFor(self, action: #selector(showParticipants), for: .touchUpInside)
    }()
    
    lazy var gift1: GiftsViewController = {
        GiftsViewController(gifts: self.gifts(), result: self, eventsDelegate: self)
    }()
    
    lazy var gift2: GiftsViewController = {
        GiftsViewController(gifts: self.gifts(), result: self,eventsDelegate: self)
    }()
    
    @objc public required convenience init(chatroomId: String) {
        self.init()
        self.roomId = chatroomId
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.addSubViews([self.background,self.roomView,self.carouselTextView,self.members])
        self.roomView.addActionHandler(actionHandler: self)
        ChatroomUIKitClient.shared.registerRoomEventsListener(listener: self)
    }
        

}

extension UIWithBusinessViewController {
    
    @objc func showParticipants() {
        DialogManager.shared.showParticipantsDialog { user in
            
        } muteMoreClosure: { user in
            
        }

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

extension UIWithBusinessViewController: GiftToChannelResultDelegate,GiftsViewActionEventsDelegate {
    
    func onGiftSendClick(item: ChatroomUIKit.GiftEntityProtocol) {
        //It can be called after completing the interaction related to the gift sending interface with the server.
        self.gift1.onUserServerHandleSentGiftComplete(gift: item)
    }
    
    func onGiftSelected(item: ChatroomUIKit.GiftEntityProtocol) {
        //When user click a gift.
    }
    
    
    func giftResult(gift: ChatroomUIKit.GiftEntityProtocol, error: ChatroomUIKit.ChatError?) {
        consoleLogInfo(error==nil ? "Sent to channel successful!":"\(error?.errorDescription ?? "")", type: .debug)
    }
    
    
}

extension UIWithBusinessViewController : ChatroomViewActionEventsDelegate {
    func onMessageBarrageClicked(message: ChatroomUIKit.ChatMessage) {
        
    }
    
    func onMessageListBarrageLongPressed(message: ChatroomUIKit.ChatMessage) {
        
    }
    
    func onKeyboardRaiseClicked() {
        
    }
    
    func onExtensionBottomItemClicked(item: ChatroomUIKit.ChatBottomItemProtocol) {
        if item.type == 2 {
            DialogManager.shared.showGiftsDialog(titles: ["Gifts","1231232"], gifts: [self.gift1,self.gift2])
        }
    }
    
    
}

extension UIWithBusinessViewController: RoomEventsListener {
    
    func onSocketConnectionStateChanged(state: ChatroomUIKit.ConnectionState) {
        
    }
    
    func onUserTokenDidExpired() {
        //SDK will auto enter current chatroom of `ChatroomContext` on reconnect success.
        ChatroomUIKitClient.shared.login(with: YourAppUser(), token: ChatroomUIKitConfig.chatToken, use: true) { error in
            if error == nil {

            }
        }
        //MARK: - Warning note
        //When the App is reopened, you need to go through the logic of SDK initialization and login creation, ChatroomView addition, etc. again.
    }
    
    func onUserTokenWillExpired() {
        ChatroomUIKitClient.shared.refreshToken(token: ChatroomUIKitConfig.chatToken)
    }
    
    func onUserLoginOtherDevice(device: String) {
        
    }
    
    func onUserUnmuted(roomId: String, userId: String, operatorId: String) {
        
    }
    
    func onUserMuted(roomId: String, userId: String, operatorId: String) {
        
    }
    
    func onUserJoined(roomId: String, user: ChatroomUIKit.UserInfoProtocol) {
        
    }
    
    func onUserBeKicked(roomId: String, reason: ChatroomUIKit.ChatroomBeKickedReason) {
        
    }
    
    func onReceiveGlobalNotify(message: ChatroomUIKit.ChatMessage) {
        if let body = message.body as? ChatTextMessageBody {
            self.carouselTextView.addTask(text: body.text)
        }
    }
    
    func onAnnouncementUpdate(roomId: String, announcement: String) {
        //toast or alert notify participants.
    }
    
    func onErrorOccur(error: ChatroomUIKit.ChatError, type: ChatroomUIKit.RoomEventsError) {
        //you can catch error then handle.
    }
    
    
}

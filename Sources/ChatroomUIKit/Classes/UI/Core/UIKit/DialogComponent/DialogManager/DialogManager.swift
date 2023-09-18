//
//  DialogManager.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/6.
//

import UIKit

@objc final public class DialogManager: NSObject {
    
    public static let shared = DialogManager()
    
    @objc public func showGiftsDialog(titles: [String],gifts: [GiftsViewController]) {
        let gift = PageContainersDialogController(pageTitles: titles, childControllers: gifts,constraintsSize: Appearance.giftContainerConstraintsSize)
        UIViewController.currentController?.presentViewController(gift)
    }
    
    @objc public func showParticipantsDialog(moreClosure: @escaping (UserInfoProtocol) -> Void,muteMoreClosure: @escaping (UserInfoProtocol) -> Void) {
        let participants = ComponentsRegister
            .shared.ParticipantsViewController.init(muteTab: false, moreClosure: moreClosure)
        let mutes = ComponentsRegister
            .shared.ParticipantsViewController.init(muteTab: true, moreClosure: muteMoreClosure)
        let container = PageContainersDialogController(pageTitles: ["participant_list_title".chatroom.localize,"Ban List".chatroom.localize], childControllers: [participants,mutes],constraintsSize: Appearance.pageContainerConstraintsSize)
        UIViewController.currentController?.presentViewController(container)
    }
    
    @objc public func showReportDialog(message: ChatMessage) {
        let report = ComponentsRegister
            .shared.ReportViewController.init(message: message)
        let vc = PageContainersDialogController(pageTitles: ["barrage_long_press_menu_report".chatroom.localize], childControllers: [report], constraintsSize: Appearance.pageContainerConstraintsSize)
        UIViewController.currentController?.presentViewController(vc)
    }
    
    @objc public func showMessageActions(actions: [ActionSheetItemProtocol],action: @escaping ActionClosure) {
        let actionSheet = ActionSheet(items: actions).cornerRadius(.small, [.topLeft,.topRight], .clear, 0)
        let vc = DialogContainerViewController(custom: actionSheet)
        for item in actionSheet.items {
            item.action = {
                vc.dismiss(animated: true)
                action($0)
            }
        }
        UIViewController.currentController?.presentViewController(vc)
    }
}

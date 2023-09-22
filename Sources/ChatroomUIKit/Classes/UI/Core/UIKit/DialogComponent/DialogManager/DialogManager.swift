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
        let actionSheet = ActionSheet(items: actions)
        actionSheet.frame = CGRect(x: 0, y: 0, width: actionSheet.frame.width, height: actionSheet.frame.height)
        let vc = DialogContainerViewController(custom: actionSheet,constraintsSize: actionSheet.frame.size)
        for item in actionSheet.items {
            item.action = { choice in
                vc.dismiss(animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    action(choice)
                }
            }
        }
        UIViewController.currentController?.presentViewController(vc)
    }
    
    @objc public func showUserActions(actions: [ActionSheetItemProtocol],action: @escaping ActionClosure) {
        let actionSheet = ActionSheet(items: actions)
        actionSheet.frame = CGRect(x: 0, y: 0, width: actionSheet.frame.width, height: actionSheet.frame.height)
        let vc = DialogContainerViewController(custom: actionSheet,constraintsSize: actionSheet.frame.size)
        for item in actionSheet.items {
            item.action = { choice in
                vc.dismiss(animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    action(choice)
                }
            }
        }
        UIViewController.currentController?.presentingViewController?.presentViewController(vc)
    }
    
    @objc public func showAlert(content: String,showCancel: Bool,showConfirm: Bool,confirmClosure: @escaping () -> Void) {
        let alert = AlertView().background(color: Theme.style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98).content(content: content)
        if showCancel {
            alert.leftButton(color: Theme.style == .dark ? UIColor.theme.neutralColor95:UIColor.theme.neutralColor3).leftButtonBorder(color: Theme.style == .dark ? UIColor.theme.neutralColor4:UIColor.theme.neutralColor7)
        }
        if showConfirm {
            alert.rightButtonBackground(color: Theme.style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5).rightButton(color: UIColor.theme.neutralColor98).rightButtonTapClosure { _ in
                
            }
        }
        let alertVC = AlertViewController(custom: alert)
        UIViewController.currentController?.presentViewController(alertVC)
    }
}

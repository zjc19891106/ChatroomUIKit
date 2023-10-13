//
//  DialogManager.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/6.
//

import UIKit

@objc final public class DialogManager: NSObject {
    
    public static let shared = DialogManager()
    
    /// Gifts list dialog will show on call the method.
    /// - Parameters:
    ///   - titles: `[String]`
    ///   - gifts: ``GiftsViewController`` array
    @objc public func showGiftsDialog(titles: [String],gifts: [GiftsViewController]) {
        let gift = PageContainersDialogController(pageTitles: titles, childControllers: gifts,constraintsSize: Appearance.giftDialogContainerConstraintsSize)
        UIViewController.currentController?.presentViewController(gift)
    }
    
    /// Participants list dialog will show on call the method.
    /// - Parameters:
    ///   - moreClosure: Callback you want to operator user info on click `...`.
    ///   - muteMoreClosure: Callback you want to operator user  info  on click `...`.
    @objc public func showParticipantsDialog(moreClosure: @escaping (UserInfoProtocol) -> Void,muteMoreClosure: @escaping (UserInfoProtocol) -> Void) {
        let participants = ComponentsRegister
            .shared.ParticipantsViewController.init(muteTab: false, moreClosure: moreClosure)
        let mutes = ComponentsRegister
            .shared.ParticipantsViewController.init(muteTab: true, moreClosure: muteMoreClosure)
        let container = PageContainersDialogController(pageTitles: ["participant_list_title".chatroom.localize,"Ban List".chatroom.localize], childControllers: [participants,mutes],constraintsSize: Appearance.pageContainerConstraintsSize)
        UIViewController.currentController?.presentViewController(container)
    }
    
    /// Message report dialog will show on call the method.
    /// - Parameter message: ``ChatMessage``
    @objc public func showReportDialog(message: ChatMessage) {
        var vc = PageContainersDialogController()
        let report = ComponentsRegister
            .shared.ReportViewController.init(message: message) {
                vc.dismiss(animated: true)
                if $0 != nil {
                    UIViewController.currentController?.showToast(toast: $0?.errorDescription ?? "",duration: 2)
                } else {
                    UIViewController.currentController?.showToast(toast: "Successful!",duration: 2)
                }
            }
        vc = PageContainersDialogController(pageTitles: ["barrage_long_press_menu_report".chatroom.localize], childControllers: [report], constraintsSize: Appearance.pageContainerConstraintsSize)
        
        UIViewController.currentController?.presentViewController(vc)
    }
    
    /// Message operation list dialog will show on call the method.General use on message long pressed.
    /// - Parameters:
    ///   - actions: ``ActionSheetItemProtocol`` array.
    ///   - action: Choice touched callback.
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
    
    /// User operation list dialog will show on call the method.
    /// - Parameters:
    ///   - actions: ``ActionSheetItemProtocol`` array.
    ///   - action: Choice touched callback.
    @objc public func showUserActions(actions: [ActionSheetItemProtocol],action: @escaping ActionClosure) {
        let actionSheet = ActionSheet(items: actions)
        actionSheet.frame = CGRect(x: 0, y: 0, width: actionSheet.frame.width, height: actionSheet.frame.height)
        let vc = DialogContainerViewController(custom: actionSheet,constraintsSize: actionSheet.frame.size)
        for item in actionSheet.items {
            item.action = { choice in
                vc.dismiss(animated: true) {
                    action(choice)
                }
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    
                }
            }
        }
        UIViewController.currentController?.presentingViewController?.presentViewController(vc)
    }
    
    /// Alert view will show on call the method.
    /// - Parameters:
    ///   - content: You want to display content.
    ///   - showCancel: Whether display cancel button or not.
    ///   - showConfirm: Whether display confirm button or not.
    ///   - confirmClosure: Callback on click confirm button.
    @objc public func showAlert(content: String,showCancel: Bool,showConfirm: Bool,confirmClosure: @escaping () -> Void) {
        let alert = AlertView(frame: CGRect(x: 0, y: 0, width: Appearance.alertContainerConstraintsSize.width, height: Appearance.alertContainerConstraintsSize.height)).background(color: Theme.style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98).content(content: content).title(title: "participant_list_button_click_menu_remove".chatroom.localize).contentTextAlignment(textAlignment: .center)
        if showCancel {
            alert.leftButton(color: Theme.style == .dark ? UIColor.theme.neutralColor95:UIColor.theme.neutralColor3).leftButtonBorder(color: Theme.style == .dark ? UIColor.theme.neutralColor4:UIColor.theme.neutralColor7).leftButton(title: "report_button_click_menu_button_cancel".chatroom.localize)
        }
        if showConfirm {
            alert.rightButtonBackground(color: Theme.style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5).rightButton(color: UIColor.theme.neutralColor98).rightButtonTapClosure { _ in
                confirmClosure()
            }.rightButton(title: "Confirm".chatroom.localize)
        }
        let alertVC = AlertViewController(custom: alert)
        UIViewController.currentController?.presentViewController(alertVC)
    }
}

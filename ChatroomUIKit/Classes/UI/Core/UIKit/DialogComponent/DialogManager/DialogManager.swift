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
    
    @objc func showParticipantsDialog() {
        
    }
    
    @objc func showMessageActions(message: ChatMessage,actions: [ActionSheetItemProtocol],action: @escaping ActionClosure) {
        let actionSheet = ActionSheet(items: actions)
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

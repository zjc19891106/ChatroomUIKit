//
//  DialogManager.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/6.
//

import UIKit

@objc final public class DialogManager: NSObject {
    
    static let shared = DialogManager()
    
    @objc func showGiftsDialog(gifts: [GiftEntityProtocol] ,sendClosure: @escaping (GiftEntityProtocol) -> Void) {
        var gift: PageContainersDialogController?
        let vc = GiftsViewController(gifts: gifts) { item in
            sendClosure(item)
            if item.sentThenClose {
                gift?.dismiss(animated: true)
            }
        }
        gift = PageContainersDialogController(pageTitles: ["Gifts"], childControllers: [vc])
        UIViewController.currentController?.presentViewController(gift!)
    }
    
    @objc func showParticipantsDialog() {
        
    }
    
    @objc func showMessageActions(entity: ChatEntity,action: @escaping ActionClosure) {
        let actionSheet = ActionSheet(items: Appearance.default.defaultMessageActions)
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

//
//  GiftsViewController.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/6.
//

import UIKit

@objcMembers open class GiftsViewController: UIViewController {
    
    private var gifts = [GiftEntityProtocol]()
    
    public private(set) lazy var giftService: GiftService? = ChatroomUIKitClient.shared.roomService?.giftService
        
    public private(set) lazy var giftsView: GiftsView = {
        GiftsView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height-BottomBarHeight), gifts: self.gifts)
    }()
    
    /// GiftsViewController init method.
    /// - Parameters:
    ///   - gifts: `Array<GiftEntityProtocol>` data source.
    @objc required public convenience init(gifts: [GiftEntityProtocol]) {
        self.init()
        self.gifts = gifts
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.addSubview(self.giftsView)
        self.giftsView.addActionHandler(actionHandler: self)
    }
    
}

extension GiftsViewController: GiftsViewActionEventsDelegate {
    /// Send button click
    /// - Parameter item: `GiftEntityProtocol`
    open func onGiftSendClick(item: GiftEntityProtocol) {
        //It can be called after completing the interaction related to the gift sending interface with the server.
        if item.sentThenClose {
            UIViewController.currentController?.dismiss(animated: true)
        }
        //If you need the server to process the deduction logic before sending the gift message after clicking send, set it to `false`, and after the processing is completed, you need to call `sendGift` method send gift message to channel.
        self.giftService?.sendGift(gift: item) { [weak self] message,error in
            if error != nil {
                let errorInfo = "Send gift message to channel failure!\nError:\(error?.errorDescription ?? "")"
                consoleLogInfo(errorInfo, type: .error)
                UIViewController.currentController?.makeToast(toast: errorInfo, duration: 3)
            } else {
                item.sendUser = ChatroomContext.shared?.currentUser
                item.giftCount = "1"
                if let implement = self?.giftService as? GiftServiceImplement,let giftMessage = message {
                    implement.notifyGiftDriveShowSelfSend(gift: item,message: giftMessage)
                }
            }
        }
    }
    
    /// Select a gift item.
    /// - Parameter item: `GiftEntityProtocol`
    open func onGiftSelected(item: GiftEntityProtocol) {
        
    }
}

//
//  GiftsViewController.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/6.
//

import UIKit

@objc public protocol GiftToChannelResultDelegate: NSObjectProtocol {
    func giftResult(gift:GiftEntityProtocol, error: ChatError?)
}

@objcMembers open class GiftsViewController: UIViewController {
    
    private var gifts = [GiftEntityProtocol]()
    
    private var resultDelegate: GiftToChannelResultDelegate?
        
    lazy var giftService: GiftService = {
        GiftServiceImplement(roomId: ChatroomContext.shared?.roomId ?? "")
    }()
        
    lazy var giftsView: GiftsView = {
        GiftsView(frame: self.view.frame, gifts: self.gifts)
    }()
    
    @objc public convenience init(gifts: [GiftEntityProtocol],result delegate: GiftToChannelResultDelegate,eventsDelegate: GiftsViewActionEventsDelegate? = nil) {
        self.init()
        self.gifts = gifts
        if let events = eventsDelegate {
            self.giftsView.addActionHandler(actionHandler: events)
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.addSubview(self.giftsView)
        self.giftsView.addActionHandler(actionHandler: self)
    }
    
    @objc public func onUserHandleSentGiftComplete(gift: GiftEntityProtocol)  {
        self.giftService.sendGift(gift: gift) { [weak self] error in
            self?.resultDelegate?.giftResult(gift: gift, error: error)
        }
    }
}

extension GiftsViewController: GiftsViewActionEventsDelegate {
    public func onGiftSendClick(item: GiftEntityProtocol) {
        if item.sentThenClose {
            self.dismiss(animated: true)
        }
    }
    
    public func onGiftSelected(item: GiftEntityProtocol) {
        
    }
    
}


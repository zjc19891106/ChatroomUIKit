//
//  GiftsViewController.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/6.
//

import UIKit

///  The result of sending a gift message to the channel
@objc public protocol GiftToChannelResultDelegate: NSObjectProtocol {
    
    /// The result of sending a gift message to the channel。
    /// - Parameters:
    ///   - gift: `GiftEntityProtocol`
    ///   - error: `ChatError`
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
    
    /// GiftsViewController init method.
    /// - Parameters:
    ///   - gifts: `Array<GiftEntityProtocol>` data source.
    ///   - delegate: `GiftToChannelResultDelegate`
    ///   - eventsDelegate: `GiftsViewActionEventsDelegate` is gifts view item click events delegate.
    @objc required public convenience init(gifts: [GiftEntityProtocol],result delegate: GiftToChannelResultDelegate,eventsDelegate: GiftsViewActionEventsDelegate? = nil) {
        self.init()
        self.gifts = gifts
        _ = self.giftsView
        if let events = eventsDelegate {
            self.giftsView.addActionHandler(actionHandler: events)
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.addSubview(self.giftsView)
    }
    
}



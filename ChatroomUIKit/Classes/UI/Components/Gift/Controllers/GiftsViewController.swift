//
//  GiftsViewController.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/6.
//

import UIKit

@objcMembers open class GiftsViewController: UIViewController {
    
    private var gifts = [GiftEntityProtocol]()
    
    private var sendClosure: ((GiftEntityProtocol) -> Void)?
    
    lazy var giftsView: GiftsView = {
        GiftsView(frame: self.view.frame, gifts: self.gifts) { [weak self] gift in
            self?.sendClosure?(gift)
        }
    }()
    
    convenience init(gifts: [GiftEntityProtocol],sendClosure: @escaping (GiftEntityProtocol) -> Void) {
        self.init()
        self.gifts = gifts
        self.sendClosure = sendClosure
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.addSubview(self.giftsView)
    }
    

}

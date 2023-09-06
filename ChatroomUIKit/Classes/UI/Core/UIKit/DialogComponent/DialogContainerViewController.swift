//
//  DialogContainerViewController.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/6.
//

import UIKit

@objc final public class DialogContainerViewController:  UIViewController, PresentedViewType {
    
    public var presentedViewComponent: PresentedViewComponent? = PresentedViewComponent(contentSize: Appearance.default.giftContainerConstraintsSize)

    var customView: UIView?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @objc public convenience init(custom: UIView,constraintsSize:CGSize = .zero) {
        self.init()
        if constraintsSize != .zero {
            self.presentedViewComponent?.contentSize = constraintsSize
        }
        self.customView = custom
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        if self.customView != nil {
            self.customView?.cornerRadius(.medium, [.topLeft,.topRight], .clear, 0)
            self.view.addSubview(self.customView!)
        }
    }
}

extension DialogContainerViewController {
    @objc private func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame = notification.keyboardEndFrame else { return }
        let duration = notification.keyboardAnimationDuration!
        UIView.animate(withDuration: duration) {
            self.customView?.frame = CGRect(x: 0, y: ScreenHeight-keyboardFrame.height - self.customView!.frame.height, width: self.customView!.frame.width, height: self.customView!.frame.height)
        }
    }
}


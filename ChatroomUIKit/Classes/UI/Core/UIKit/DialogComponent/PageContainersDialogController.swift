//
//  DialogViewController.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/6.
//

import UIKit

@objc public class PageContainersDialogController: UIViewController, PresentedViewType {
    
    public var presentedViewComponent: PresentedViewComponent? = PresentedViewComponent(contentSize: Appearance.pageContainerConstraintsSize)
    
    private var pageTitles = [String]()
    
    private var childControllers = [UIViewController]()

    lazy var container: PageContainer = {
        PageContainer(frame: CGRect(x: 0, y: 0, width: self.presentedViewComponent?.contentSize.width ?? 0, height: self.presentedViewComponent?.contentSize.height ?? 0), viewControllers: self.childControllers, indicators: self.pageTitles).cornerRadius(.medium, [.topLeft,.topRight], .clear, 0)
    }()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @objc public required convenience init(pageTitles:[String],childControllers: [UIViewController],constraintsSize: CGSize = .zero) {
        self.init()
        if constraintsSize != .zero {
            self.presentedViewComponent?.contentSize = constraintsSize
        }
        self.pageTitles = pageTitles
        self.childControllers = childControllers
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.container)
    }
}

extension PageContainersDialogController {
    @objc private func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame = notification.keyboardEndFrame else { return }
        let duration = notification.keyboardAnimationDuration!
        UIView.animate(withDuration: duration) {
            self.container.frame = CGRect(x: 0, y: ScreenHeight-keyboardFrame.height - self.container.frame.height, width: self.container.frame.width, height: self.container.frame.height)
        }
    }
}

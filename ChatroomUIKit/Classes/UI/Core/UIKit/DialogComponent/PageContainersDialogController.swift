//
//  DialogViewController.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/6.
//

import UIKit
/**
     A controller that manages a page container which displays a collection of child view controllers in a paged interface.
     
     The `presentedViewComponent` property is used to set the size of the page container. The `pageTitles` property is used to set the titles of the pages in the container. The `childControllers` property is used to set the child view controllers to be displayed in the container.
     
     The `container` property is a lazy var that returns a `PageContainer` instance with the specified frame, view controllers, and page titles. It also sets the corner radius of the container view.
*/
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

    /**
     Initializes a PageContainersDialogController with the given page titles, child view controllers, and optional constraints size.

     - Parameters:
         - pageTitles: An array of strings representing the titles of each page.
         - childControllers: An array of UIViewControllers representing the child view controllers for each page.
         - constraintsSize: An optional CGSize representing the size of the constraints for the presented view component.

     - Returns: A PageContainersDialogController instance.
     */
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

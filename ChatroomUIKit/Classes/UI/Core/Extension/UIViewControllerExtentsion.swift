//
//  UIViewControllerExtentsion.swift
//  Pods
//
//  Created by 朱继超 on 2022/8/3.
//

import Foundation
import UIKit
import QuartzCore

/// Extension for UIViewController to provide custom presentation and dismissal animations.
public extension UIViewController {
    
    /// Presents a view controller with a push animation.
    /// - Parameters:
    ///   - controller: The view controller to present.
    ///   - completion: A closure to be executed after the presentation finishes.
    func presentViewControllerPush(_ controller: UIViewController, completion: (() -> Void)? = nil) {
        controller.modalTransitionStyle = .crossDissolve
        let transition = CATransition()
        transition.duration = 0.35
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        self.view.superview?.layer.add(transition, forKey: "presentPush")
        if self.responds(to: #selector(self.present(_:animated:completion:))) {
            self.present(controller, animated: true, completion: completion)
        }
    }
    
    /// Dismisses the current view controller with a pop animation.
    /// - Parameter completion: A closure to be executed after the dismissal finishes.
    func dismissPopViewController(completion: (() -> Void)? = nil) {
        let transition = CATransition()
        transition.duration = 0.35
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.superview?.layer.add(transition, forKey: "presentPush")
        if self.responds(to: #selector(self.dismiss(animated:completion:))) {
            self.dismiss(animated: true, completion: completion)
        }
    }
    
}

extension UIViewController {
    
    func makeToast(toast content: String, style: UIBlurEffect.Style = .light, duration: TimeInterval = 2.0) {
        let toastView = UIVisualEffectView(effect: UIBlurEffect(style: style)).cornerRadius(.small)
        toastView.alpha = 0
        toastView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toastView)
        
        NSLayoutConstraint.activate([
            toastView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            toastView.widthAnchor.constraint(greaterThanOrEqualToConstant: ScreenWidth - 40),
            toastView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])
        
        let label = UILabel().text(content).textColor(style == .light ? UIColor.theme.neutralColor3:UIColor.theme.neutralColor98).textAlignment(.center).numberOfLines(0)
        label.translatesAutoresizingMaskIntoConstraints = false
        toastView.contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -8),
            label.topAnchor.constraint(equalTo: toastView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: toastView.bottomAnchor, constant: -8)
        ])
        
        UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseOut, animations: {
            toastView.alpha = 1
        }, completion: { (isCompleted) in
            toastView.removeFromSuperview()
        })
    }
}

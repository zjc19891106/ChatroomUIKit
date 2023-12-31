//
//  GlobalBoardcastView.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/13.
//

import UIKit

@objc public protocol IGlobalBoardcastViewDrive: NSObjectProtocol {
    
    /// Display text on received global notify message.
    /// - Parameter text: show text
    func showNewNotify(text: String)
}

@objc public class GlobalBoardcastView: UIView {
        
    private var queue: AnimationQueue = AnimationQueue()
    
    private var animationContext = [String]()
    
    private var originContentOffset = CGPoint.zero
        
    public private(set) lazy var voiceIcon: UIImageView = {
        UIImageView(frame: CGRect(x: 4, y: 2, width: (self.frame.height-4), height: (self.frame.height-4))).image(Appearance.notifyMessageIcon).contentMode(.scaleAspectFit)
    }()
    
    public private(set) lazy var scroll: UIScrollView = {
        let container = UIScrollView(frame: CGRect(x: self.voiceIcon.frame.maxX+5, y: 0, width: self.frame.width-self.voiceIcon.frame.maxX-15, height: self.frame.height))
        container.showsVerticalScrollIndicator = false
        container.showsHorizontalScrollIndicator = false
        container.isUserInteractionEnabled = false
        container.bounces = false
        return container
    }()
    
    lazy var textCarousel: UILabel = {
        UILabel(frame: CGRect(x: 0, y: 0, width: .infinity, height: self.frame.height-4)).textColor(Appearance.notifyTextColor).backgroundColor(.clear).lineBreakMode(.byCharWrapping).numberOfLines(1)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    /// GlobalBoardcastView init method
    /// - Parameters:
    ///   - originPoint: GlobalBoardcastView's origin point.
    ///   - width: GlobalBoardcastView's width.
    ///   - font: GlobalBoardcastView's text font.
    ///   - textColor: GlobalBoardcastView's text color.
    ///   - hiddenIcon: Whether hidden icon or not.
    @objc public required convenience init(originPoint: CGPoint ,width: CGFloat, font: UIFont, textColor: UIColor, hiddenIcon: Bool = false) {
        self.init(frame: CGRect(x: originPoint.x, y: originPoint.y, width: width, height: font.lineHeight+4))
        if hiddenIcon {
            self.addSubViews([self.scroll])
        } else {
            self.addSubViews([self.voiceIcon,self.scroll])
        }
        self.voiceIcon.isHidden = hiddenIcon
        self.scroll.addSubview(self.textCarousel)
        self.originContentOffset = self.scroll.contentOffset
        self.textCarousel.font(font)
        self.textCarousel.textColor = textColor
        Theme.registerSwitchThemeViews(view: self)
    }
    
    private func textAnimation() {
        self.switchTheme(style: Theme.style)
        self.alpha = 1
        self.scroll.setContentOffset(self.originContentOffset, animated: false)

        let text = self.animationContext.first ?? ""
        let width = text.chatroom.sizeWithText(font: self.textCarousel.font, size: CGSize(width: 9999, height: self.frame.height-4)).width
        var duration: CGFloat = 2
        duration += CGFloat(text.count)*0.25
        if width+(self.frame.height-13) > self.frame.width {
            self.scroll.frame = CGRect(x: (self.voiceIcon.isHidden ? 15:self.voiceIcon.frame.maxX+5), y: 0, width: self.frame.width - (self.voiceIcon.isHidden ? 15:self.voiceIcon.frame.maxX) - 15, height: self.frame.height)
            self.textCarousel.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.height)
            self.scroll.contentSize = CGSize(width: width+10, height: self.frame.height)
            UIView.animate(withDuration: duration, delay: 2, usingSpringWithDamping: 1, initialSpringVelocity: 0.15, options: .curveLinear) {
                self.queue.isAnimating = true
                self.alpha = 1
                self.textCarousel.text = text
                let contentOffset = CGPoint(x: self.scroll.contentSize.width - self.scroll.bounds.width-0, y: 0)
                self.scroll.setContentOffset(contentOffset, animated: false)
            } completion: { finished in
                if finished {
                    self.queue.isAnimating = false
                    self.animationContext.removeFirst()
                    if self.animationContext.count > 1 {
                        DispatchQueue.main.async {
                            self.perform(#selector(self.nextTask), with: nil, afterDelay: 1)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.perform(#selector(self.hidden), with: nil, afterDelay: 1)
                        }
                    }
                }
            }
        } else {
            self.scroll.frame = CGRect(x: (self.voiceIcon.isHidden ? 15:self.voiceIcon.frame.maxX+5), y: 0, width: self.frame.width - (self.voiceIcon.isHidden ? 15:self.voiceIcon.frame.maxX) - 15, height: self.frame.height)
            self.textCarousel.frame = CGRect(x: 0, y: 0, width: self.scroll.frame.width, height: self.frame.height)
            UIView.animate(withDuration: duration, delay: 2, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveLinear) {
                self.queue.isAnimating = true
                self.alpha = 1
                self.textCarousel.text = text
            } completion: { finished in
                if finished {
                    self.queue.isAnimating = false
                    self.animationContext.removeFirst()
                    if self.animationContext.count > 1 {
                        DispatchQueue.main.async {
                            self.perform(#selector(self.nextTask), with: nil, afterDelay: 2)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.perform(#selector(self.hidden), with: nil, afterDelay: 3)
                        }
                    }
                }
            }
        }
    }
    
    @objc private func hidden() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        }
    }
    
    /// Add text animation task.
    /// - Parameter text: Display text.
    @objc public func addTask(text: String) {
        self.animationContext.append(text)
        self.queue.addAnimation(animation: {
            self.textAnimation()
        }, delay: 1)
    }
    
    @objc private func nextTask() {
        self.queue.startNextAnimation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension GlobalBoardcastView: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.backgroundColor = style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5
    }
}

extension GlobalBoardcastView: IGlobalBoardcastViewDrive {
    public func showNewNotify(text: String) {
        self.addTask(text: text)
    }
}

final class AnimationQueue {
    
    var animations: [() -> Void] = []
    
    var isAnimating: Bool = false
    
    func addAnimation(animation: @escaping () -> Void, delay: TimeInterval = 1) {
        let delayedAnimation = {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                animation()
                self.startNextAnimation()
            }
        }
        
        self.animations.append(delayedAnimation)
        if !self.isAnimating {
            self.startNextAnimation()
        }
    }
    
    func startNextAnimation() {
        guard !self.isAnimating else {
            return
        }
        
        if let animation = self.animations.first {
            self.isAnimating = true
            animation()
            self.animations.removeFirst()
        } else {
            self.isAnimating = false
        }
    }
}

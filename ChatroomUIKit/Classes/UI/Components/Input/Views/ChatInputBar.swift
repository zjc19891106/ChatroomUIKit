//
//  ChatInputBar.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/4.
//

import UIKit

@objcMembers open class ChatInputBar: UIView {
    
    var keyboardHeight = CGFloat(0)
    
    var rawHeight: CGFloat = 0
    
    var rawTextHeight: CGFloat = 0
    
    var rawFrame: CGRect = .zero
    
    public var sendClosure: ((String) -> Void)?
    
    public var changeEmojiClosure: ((Bool) -> Void)?
    
    lazy var rightView: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.frame.width-87, y: 12, width: 30, height: 30)).addTargetFor(self, action: #selector(changeToEmoji), for: .touchUpInside).backgroundColor(.clear)
    }()
    
    public lazy var inputField: PlaceHolderTextView = {
        PlaceHolderTextView(frame: .zero).delegate(self).font(UIFont.theme.bodyLarge).backgroundColor(.clear).backgroundColor(UIColor.theme.neutralColor95).delegate(self)
    }()
    
    lazy var send: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.frame.width - 49, y: 12, width: 30, height: 30)).backgroundColor(.clear).image(UIImage(named: "airplane", in: .chatroomBundle, with: nil), .normal).addTargetFor(self, action: #selector(sendMessage), for: .touchUpInside)
    }()
    
    private var limitCount: Int {
        var count = 30
        if NSLocale.preferredLanguages.first!.hasPrefix("en") {
            count = 50
        }
        return count
    }
        
    
    var emoji: ChatEmojiView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    /// Description ChatInputBar init method
    /// - Parameters:
    ///   - frame: CGRect
    ///   - text: `String` value
    ///   - placeHolder: `String` value
    @objc required public convenience init(frame: CGRect,text: String? = nil,placeHolder: String? = nil) {
        self.init(frame: frame)
        self.rawHeight = frame.height
        self.rawTextHeight = self.rawHeight-16
        self.rawFrame = frame
        self.addSubViews([self.inputField, self.rightView,self.send])
        self.rightView.setImage(UIImage(named: "emojiKeyboard", in: Bundle.chatroomBundle, with: nil)?.withTintColor(UIColor.theme.neutralColor3), for: .normal)
        self.rightView.setImage(UIImage(named: "textKeyboard", in: Bundle.chatroomBundle, with: nil)?.withTintColor(UIColor.theme.neutralColor3), for: .selected)
        self.inputField.translatesAutoresizingMaskIntoConstraints = false
        self.inputField.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12).isActive = true
        self.inputField.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -99).isActive = true
        self.inputField.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        self.inputField.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
        self.inputField.cornerRadius(Appearance.inputBarCorner)
        self.inputField.placeHolder = Appearance.inputPlaceHolder.chatroom.localize
        self.inputField.textContainerInset = UIEdgeInsets(top: 7, left: CGFloat(Appearance.inputBarCorner.rawValue), bottom: 7, right: CGFloat(Appearance.inputBarCorner.rawValue))
        self.inputField.tintColor = UIColor.theme.primaryColor5
        self.inputField.placeHolderColor = UIColor.theme.neutralColor6
        self.inputField.textColor = UIColor.theme.neutralColor1
        self.inputField.font = UIFont.theme.bodyLarge
        if text != nil {
            self.inputField.text = text
        }
        if placeHolder != nil {
            self.inputField.placeHolder = placeHolder ?? "Aa"
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIApplication.keyboardWillHideNotification, object: nil)
        self.backgroundColor = UIColor.theme.neutralColor98
        
        
        Theme.registerSwitchThemeViews(view: self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        inputField.removeFromSuperview()
        emoji?.removeFromSuperview()
        emoji = nil
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
}

extension ChatInputBar: UITextViewDelegate {
    
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.sendMessage()
            return false
        } else {
            let textHeight = self.inputField.sizeThatFits(CGSize(width: self.inputField.frame.width, height: 9999)).height
            if textHeight > self.rawTextHeight {
                let increment = textHeight - self.rawTextHeight
                self.rawTextHeight += increment
                self.rawHeight = self.rawTextHeight + 16
                if textHeight > Appearance.maxInputHeight {
                    self.frame = CGRect(x: 0, y: ScreenHeight - (Appearance.maxInputHeight+16) - self.keyboardHeight, width: self.frame.width, height: Appearance.maxInputHeight+16)
                } else {
                    self.frame = CGRect(x: 0, y: ScreenHeight - self.rawHeight - self.keyboardHeight, width: self.frame.width, height: self.rawHeight)
                }
            }
            return true
        }
    }
    
    @objc func sendMessage() {
        self.hiddenInputBar()
        self.rightView.isSelected = false
        if !self.inputField.attributedText.toString().isEmpty {
            self.sendClosure?(self.inputField.attributedText.toString().trimmingCharacters(in: .whitespacesAndNewlines))
        }
        self.inputField.text = nil
        self.inputField.attributedText = nil
        self.frame = self.rawFrame
        self.rawHeight = self.rawFrame.height
        self.rawTextHeight = self.rawHeight-16
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for view in subviews.reversed() {
            if view.isKind(of: type(of: view)),view.frame.contains(point){
                let childPoint = self.convert(point, to: view)
                let childView = view.hitTest(childPoint, with: event)
                return childView
            }
        }
        self.hiddenInputBar()
        return super.hitTest(point, with: event)
    }

    @objc func changeToEmoji() {
        self.rightView.isSelected = !self.rightView.isSelected
        self.changeEmojiClosure?(self.rightView.isSelected)
        if self.rightView.isSelected {
            self.inputField.resignFirstResponder()
        } else {
            self.inputField.becomeFirstResponder()
        }
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        if !self.inputField.isFirstResponder {
            return
        }
        let frame = notification.chatroom.keyboardEndFrame
        let duration = notification.chatroom.keyboardAnimationDuration
        self.keyboardHeight = frame!.height
        UIView.animate(withDuration: duration!) {
            self.frame = CGRect(x: 0, y: ScreenHeight - self.rawFrame.height - frame!.height, width: self.frame.width, height: self.rawFrame.height)
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        let frame = notification.chatroom.keyboardEndFrame
        let duration = notification.chatroom.keyboardAnimationDuration
        self.keyboardHeight = frame!.height
        self.frame = CGRect(x: 0, y: self.frame.origin.y, width: self.frame.width, height: self.keyboardHeight + 5 + 60)
        let emoji = ChatEmojiView(frame: CGRect(x: 0, y: self.inputField.frame.maxY, width: self.frame.width, height: self.keyboardHeight)).tag(124).backgroundColor(UIColor.theme.neutralColor98)
        self.emoji = emoji
        emoji.emojiClosure = { [weak self] in
            guard let self = self else { return }
            emoji.deleteEmoji.isEnabled = true
            emoji.deleteEmoji.isUserInteractionEnabled = true
            self.inputField.attributedText = self.convertText(text: self.inputField.attributedText, key: $0)
        }
        emoji.deleteClosure = { [weak self] in
            if self?.inputField.text?.count ?? 0 > 0 {
                self?.inputField.deleteBackward()
                emoji.deleteEmoji.isEnabled = true
                emoji.deleteEmoji.isUserInteractionEnabled = true
            } else {
                emoji.deleteEmoji.isEnabled = false
                emoji.deleteEmoji.isUserInteractionEnabled = false
            }
        }
        emoji.isHidden = true
        addSubview(emoji)
        UIView.animate(withDuration: duration!) {
            emoji.isHidden = false
        }
    }
    
    @objc public func hiddenInputBar() {
        self.inputField.resignFirstResponder()
        UIView.animate(withDuration: 0.3) {
            self.frame = CGRect(x: 0, y: ScreenHeight, width: self.frame.width, height: self.keyboardHeight + 60)
        }
        self.emoji?.removeFromSuperview()
        self.rightView.isSelected = false
    }
    
    /// Description Raise input bar
    @objc public func show() {
        self.inputField.becomeFirstResponder()
    }
    
    /// Description Hidden input bar
    @objc public func hiddenInput() {
        self.hiddenInputBar()
    }

    func convertText(text: NSAttributedString?, key: String) -> NSAttributedString {
        let attribute = NSMutableAttributedString(attributedString: text!)
        let attachment = NSTextAttachment()
        attachment.image = ChatEmojiConvertor.shared.emojiMap.isEmpty ? UIImage(named: key, in: .chatroomBundle, with: nil):ChatEmojiConvertor.shared.emojiMap[key]
        attachment.bounds = CGRect(x: 0, y: -3.5, width: 18, height: 18)
        let imageText = NSMutableAttributedString(attachment: attachment)
        if #available(iOS 11.0, *) {
            imageText.addAttributes([.accessibilityTextCustom: key], range: NSMakeRange(0, imageText.length))
        } else {
            assert(false,"failed add accessibility custom text!")
        }
        attribute.append(imageText)
        return attribute
    }
    
    public func dismissKeyboard() {
        self.inputField.resignFirstResponder()
    }
}

extension ChatInputBar: ThemeSwitchProtocol {
    
    public func switchTheme(style: ThemeStyle) {
        self.rightView.setImage(UIImage(named: "emojiKeyboard", in: .chatroomBundle, with: nil)?.withTintColor(style == .dark ? UIColor.theme.neutralColor95:UIColor.theme.neutralColor3, renderingMode: .automatic), for: .normal)
        self.rightView.setImage(UIImage(named: "textKeyboard", in: .chatroomBundle, with: nil)?.withTintColor(style == .dark ? UIColor.theme.neutralColor95:UIColor.theme.neutralColor3, renderingMode: .automatic), for: .selected)
        var image = UIImage(named: "airplane", in: .chatroomBundle, with: nil)
        if style == .dark {
            image = image?.withTintColor(UIColor.theme.primaryColor6)
        }
        self.send.setImage(image, for: .normal)
        self.viewWithTag(124)?.backgroundColor(style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98)
        self.inputField.backgroundColor(style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor95)
        self.inputField.tintColor = style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5
        self.inputField.placeHolderColor = style == .dark ? UIColor.theme.neutralColor4:UIColor.theme.neutralColor6
        self.inputField.textColor = style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1
        self.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
    }
    
    public func switchHues() {
        self.switchTheme(style: .dark)
    }
    
}

public extension NSAttributedString {
    func toString() -> String {
        let result = NSMutableAttributedString(attributedString: self)
        var replaceList: [(NSRange, String)] = []
        if #available(iOS 11.0, *) {
            result.enumerateAttribute(.accessibilityTextCustom, in: NSRange(location: 0, length: result.length), using: { value, range, _ in
                if let value = value as? String {
                    for i in range.location..<range.location + range.length {
                        replaceList.append((NSRange(location: i, length: 1), value))
                    }
                }
            })
        } else {
            assert(false,"failed add replace custom text!")
        }
        for i in replaceList.reversed() {
            result.replaceCharacters(in: i.0, with: i.1)
        }
        return result.string
    }
}


//
//  PlaceHolderTextView.swift
//  ZSwiftBaseLib
//
//  Created by 朱继超 on 2020/12/16.
//

import Foundation
import UIKit

@objcMembers public class PlaceHolderTextView: UITextView {
    
    public var placeHolder: String = "" {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public var placeHolderColor: UIColor = UIColor.gray {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override public var font: UIFont?{
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override public var text: String? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override public var attributedText: NSAttributedString!{
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        if self.font == nil {
            self.font = UIFont.theme.bodyLarge
        }
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChanged(noti:)), name: UITextView.textDidChangeNotification, object: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc fileprivate func textDidChanged(noti: NSNotification)  {
        self.setNeedsDisplay()
        //MARK: - this is ignore emoji
//        let modes = UITextInputMode.activeInputModes.compactMap {
//            $0.primaryLanguage == "emoji"
//        }
//        if modes.count > 0 {
//            self.text = String(self.text!.removeLast())
//        }
    }
    
    public override func draw(_ rect: CGRect) {
        if self.hasText {
            return
        }
        var newRect = CGRect()
        let size = self.placeHolder.chatroom.sizeWithText(font: self.font ?? UIFont.theme.bodyLarge, size: rect.size)
        newRect.size.width = size.width
        newRect.size.height = size.height
        newRect.origin.x = 12
        newRect.origin.y = (rect.height-size.height)/2.0
        
        (self.placeHolder as NSString).draw(in: newRect, withAttributes: [.font: self.font ?? UIFont.theme.bodyLarge,.foregroundColor: self.placeHolderColor])
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsDisplay()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: self)
    }
    
}


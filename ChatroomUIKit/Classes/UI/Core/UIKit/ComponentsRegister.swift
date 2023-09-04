//
//  ComponentsRegister.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/1.
//

import UIKit

@objcMembers final public class ComponentsRegister: NSObject {
    
    public static let shared: ComponentsRegister = ComponentsRegister()
    
    public var EmojiView: ChatEmojiView.Type = ChatEmojiView.self
    
    public var GiftBarragesView: GiftsBarrageList.Type = GiftsBarrageList.self
    
    public var GiftBarragesViewCell: GiftBarrageCell.Type = GiftBarrageCell.self
    
    public var GiftsCell: GiftEntityCell.Type = GiftEntityCell.self
    
    public var InputBar: ChatInputBar.Type = ChatInputBar.self
}

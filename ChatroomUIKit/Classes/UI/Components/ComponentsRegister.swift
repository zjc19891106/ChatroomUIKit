//
//  ComponentsRegister.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/1.
//

import UIKit

final public class ComponentsRegister: NSObject {
    
    static let shared = ComponentsRegister()
    
    var EmojiView: UIView.Type = ChatEmojiView.self
    
    var GiftBarragesView: UIView.Type = GiftsBarrageList.self
    
    var GiftBarragesViewCell: UIView.Type = GiftBarrageCell.self
}

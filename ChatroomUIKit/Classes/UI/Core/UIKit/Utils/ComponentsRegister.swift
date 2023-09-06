//
//  ComponentsRegister.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/1.
//

import UIKit

fileprivate let component = ComponentsRegister()

@objcMembers public class ComponentsRegister: NSObject {
    
    public class var shared: ComponentsRegister {
        component
    }
            
    public var GiftBarragesViewCell: GiftBarrageCell.Type = GiftBarrageCell.self
    
    public var GiftsCell: GiftEntityCell.Type = GiftEntityCell.self
        
    public var InputBar: ChatInputBar.Type = ChatInputBar.self
    
    public var barrageStyle: ChatBarrageCellStyle = .all
}

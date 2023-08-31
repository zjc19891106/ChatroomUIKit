//
//  NSObjectExtension.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/8/31.
//

import Foundation

public extension NSObject {
    var chatroom: Chatroom<NSObject> {
        return Chatroom.init(self)
    }
    
}

public extension Chatroom where Base == NSObject {
    
    var swiftClassName: String? {
        let className = type(of: base).description().components(separatedBy: ".").last
        return  className
    }
}



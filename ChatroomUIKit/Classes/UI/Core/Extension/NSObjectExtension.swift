//
//  NSObjectExtension.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/8/31.
//

import Foundation

public extension NSObject {
    var swiftClassName: String? {
        let className = type(of: self).description().components(separatedBy: ".").last
        return  className
    }
    
}




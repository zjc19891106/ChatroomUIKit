//
//  NSObjectExtension.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/8/31.
//

import Foundation
import ObjectiveC.runtime

public extension NSObject {
    
    class func allSubclasses() -> [AnyClass] {
        var count: UInt32 = 0
        let classes = objc_copyClassList(&count)!
        var subclasses = [AnyClass]()
        
        for i in 0..<Int(count) {
            let currentClass: AnyClass = classes[i]
            if class_getSuperclass(currentClass) == self {
                subclasses.append(currentClass)
            }
        }
        
        return subclasses
    }
    
    var swiftClassName: String? {
        let className = type(of: self).description().components(separatedBy: ".").last
        return  className
    }
    
}




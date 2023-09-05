//
//  BundleExtension.swift
//  Picker
//
//  Created by 朱继超 on 2023/8/30.
//

import Foundation

fileprivate var ChatroomResourceBundle: Bundle?

public extension Bundle {
    class var chatroomBundle: Bundle {
        if ChatroomResourceBundle != nil {
            return ChatroomResourceBundle!
        }
        let bundlePath = Bundle.main.path(forResource: "ChatRoomResource", ofType: "bundle") ?? ""
        ChatroomResourceBundle = Bundle(path:  bundlePath) ?? .main
        return ChatroomResourceBundle!
        
    }
}

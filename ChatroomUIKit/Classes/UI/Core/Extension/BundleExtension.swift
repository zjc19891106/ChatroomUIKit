//
//  BundleExtension.swift
//  Picker
//
//  Created by 朱继超 on 2023/8/30.
//

import Foundation

public let ChatroomResourceBundle = Bundle(path: Bundle.main.path(forResource: "ChatroomResource", ofType: "bundle") ?? "") ?? Bundle.main

public extension Bundle {
    class var chatroomBundle: Bundle { ChatroomResourceBundle }
}

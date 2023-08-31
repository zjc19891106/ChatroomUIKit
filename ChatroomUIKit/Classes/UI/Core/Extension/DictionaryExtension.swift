//
//  DictionaryExtension.swift
//  TestPods
//
//  Created by 朱继超 on 2021/3/16.
//

import Foundation

public extension Dictionary {
    var chatroom: Chatroom<Self> {
        return Chatroom.init(self)
    }
    
}

public extension Chatroom where Base == Dictionary<String, Any> {
    var jsonString: String {
        if (!JSONSerialization.isValidJSONObject(base)) {
            print("无法解析出JSONString")
            return ""
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: base, options: [])
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            assert(false, "\(error)")
        }
        return ""
    }
}

//
//  DataExtension.swift
//  ZSwiftBaseLib
//
//  Created by 朱继超 on 2020/12/17.
//

import Foundation

public extension Data {
    
    var chatroom: Chatroom<Self> {
        return Chatroom.init(self)
    }
}

public extension Chatroom where Base == Data {
    func toDictionary() -> Dictionary<String,Any>? {
        var dic: Dictionary<String,Any>?
        do {
            dic = try JSONSerialization.jsonObject(with: base, options: .allowFragments) as? Dictionary<String,Any>
        } catch {
            assert(false, "\(error)")
        }
        return dic
    }
    
    func toDictionaryArray() -> [Dictionary<String,Any>]? {
        var dic: [Dictionary<String,Any>]?
        do {
            dic = try JSONSerialization.jsonObject(with: base, options: .allowFragments) as? [Dictionary<String,Any>]
        } catch {
            assert(false, "\(error)")
        }
        return dic
    }
}

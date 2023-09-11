//
//  ActionSheetItem.swift
//  Picker
//
//  Created by 朱继超 on 2023/8/28.
//

import Foundation


public typealias ActionClosure = ((ActionSheetItemProtocol) -> Void)

@objc public enum ActionSheetItemType: Int {
    case normal
    case destructive
}

@objc public protocol ActionSheetItemProtocol: NSObjectProtocol {
    var title: String {set get}
    var type: ActionSheetItemType {set get}
    var tag: String {set get}
    var action: ActionClosure? {set get}
    var image: UIImage? {set get}
}

@objcMembers public final class ActionSheetItem: NSObject,ActionSheetItemProtocol {
    

   @objc public convenience init(title: String, type: ActionSheetItemType,tag: String, action: @escaping ActionClosure) {
        self.init()
        self.action = action
        self.title = title
        self.type = type
        self.tag = tag
   }
    
    @objc public convenience init(title: String, type: ActionSheetItemType,tag: String) {
         self.init()
         self.title = title
         self.type = type
         self.tag = tag
    }

    public var title: String = ""
    public var type: ActionSheetItemType = .normal
    public var action: ActionClosure?
    public var image: UIImage? = nil
    public var tag: String = ""
}

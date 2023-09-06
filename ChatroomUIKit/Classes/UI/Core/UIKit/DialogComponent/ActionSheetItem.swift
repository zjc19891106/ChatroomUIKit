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
    var action: ActionClosure? {set get}
    var image: UIImage? {set get}
}

@objcMembers public final class ActionSheetItem: NSObject,ActionSheetItemProtocol {

   @objc public convenience init(title: String, type: ActionSheetItemType, action: @escaping ActionClosure) {
        self.init()
        self.title = title
        self.type = type
        self.action = action
   }
    
    @objc public convenience init(title: String, type: ActionSheetItemType) {
         self.init()
         self.title = title
         self.type = type
    }

    public var title: String = ""
    public var type: ActionSheetItemType = .normal
    public var action: ActionClosure?
    public var image: UIImage? = nil
}

//
//  Contants.swift
//  ZSwiftBaseLib
//
//  Created by 朱继超 on 2020/12/16.
//

import Foundation
import UIKit

public let ScreenWidth = UIScreen.main.bounds.width

public let ScreenHeight = UIScreen.main.bounds.height

public let edgeZero: UIEdgeInsets = .zero

public let BottomBarHeight = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0

public let StatusBarHeight :CGFloat = UIApplication.shared.chatroom.keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0

public let NavigationHeight :CGFloat = StatusBarHeight + 44

//project wrapper
public struct Chatroom<Base> {
    var base: Base
    init(_ base: Base) {
        self.base = base
    }
}







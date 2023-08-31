//
//  Theme.swift
//  Picker
//
//  Created by 朱继超 on 2023/8/30.
//

import Foundation
import UIKit.UIView

/// Contain light and dark themes of the chat room UIKit.
@objc public enum ThemeStyle: UInt {
    case light
    case dark
}

/// Description When the system theme changes, you can use this static method to switch between the light and dark themes of the chat room UIKit.
@objc public protocol ThemeSwitchProtocol: NSObjectProtocol {
    
    /// Description When some view Implement the protocol method,you can use `Theme.switchTheme(style: .dark)` to switch theme.
    /// - Parameter style: ThemeStyle
    func switchTheme(style: ThemeStyle)
}


/// Description The theme switching class is used for users to switch themes or register some user's own views that comply with the ThemeSwitchProtocol protocol.
@objcMembers open class Theme: NSObject {
    
    private static var registerViews = NSMutableSet()
    
    /// Description Register some user's own views that Implement with the ThemeSwitchProtocol protocol.
    /// - Parameter view: The view conform ThemeSwitchProtocol.
    /// How to use?
    /// `Theme.registerSwitchThemeViews(view: Some view implement ThemeSwitchProtocol)`
    public static func registerSwitchThemeViews(view: ThemeSwitchProtocol) {
        if registerViews.contains(view) {
            return
        }
        registerViews.add(view)
    }
    
    /// Description The method
    /// - Parameter style: ThemeStyle
    /// How to use?
    /// `Theme.switchTheme(style: .dark)`
    @MainActor public static func switchTheme(style: ThemeStyle) {
        for view in registerViews {
            if let themeView = view as? ThemeSwitchProtocol {
                themeView.switchTheme(style: style)
            }
        }
    }
        
}


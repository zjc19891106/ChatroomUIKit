//
//  FontTheme.swift
//  Picker
//
//  Created by 朱继超 on 2023/8/29.
//

import Foundation
import UIKit

public extension UIFont {
    
    @objc static let theme: FontTheme = FontTheme()
    
    @objcMembers class FontTheme: NSObject {
        
        var headlineLarge = UIFont.systemFont(ofSize: 20, weight: .semibold)
        
        var headlineMedium = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        var headlineSmall = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        var headlineExtraSmall = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        var titleLarge = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        var titleMedium = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        var titleSmall = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        var labelLarge = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        var labelMedium = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        var labelSmall = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        var labelExtraSmall = UIFont.systemFont(ofSize: 11, weight: .medium)
        
        var bodyLarge = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        var bodyMedium = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        var bodySmall = UIFont.systemFont(ofSize: 12, weight: .regular)
        
        var bodyExtraSmall = UIFont.systemFont(ofSize: 11, weight: .regular)
        
        var giftNumberFont = UIFont(name: "HelveticaNeue-BoldItalic", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold)

    }
        
        
}

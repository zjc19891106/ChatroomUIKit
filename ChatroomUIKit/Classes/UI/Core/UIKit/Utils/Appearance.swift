//
//  Appearance.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/6.
//

import UIKit

/// An object containing visual configuration for whole application.
@objcMembers final public class Appearance: NSObject {
        
    /// You can change the width of a single option with `PageContainerTitleBar` in the popup container by setting the current property
    public static var pageContainerTitleBarItemWidth: CGFloat = 114
    
    /// PageContainersDialogController constraints size.
    public static var pageContainerConstraintsSize = CGSizeMake(ScreenWidth, ScreenHeight*(3/5.0))
    
    /// Gifts dialog controllers constraints size.
    public static var giftContainerConstraintsSize = CGSizeMake(ScreenWidth, ScreenHeight/2.0)
    
    /// You can change the overall cell layout style of the barrage area by setting the current properties.
    public static var barrageCellStyle: ChatBarrageCellStyle = .all
    
    /// The  property must has all hues.If you want to change it.
    /// The property for usage `Theme.switchHues()`.Please set the current property before you call the `Theme.switchHues()` method.
    public static var colorHues: [CGFloat] = [Appearance.primaryHue,Appearance.secondaryHue,Appearance.errorHue,Appearance.neutralHue,Appearance.neutralSpecialHue,Appearance.gradientEndHue]
    
    /// You can change the hue of the base color, and then change the thirteen UIColor objects of the related color series. The UI components that use the relevant color series in the chat room UIKit will also change accordingly. The default value is 203/360.0.
    public static var primaryHue: CGFloat = 203/360.0
    
    /// You can change the hue of the base color, and then change the thirteen UIColor objects of the related color series. The UI components that use the relevant color series in the chat room UIKit will also change accordingly . The default value is 155/360.0.
    public static var secondaryHue: CGFloat = 155/360.0
    
    /// You can change the hue of the base color, and then change the thirteen UIColor objects of the related color series. The UI components that use the relevant color series in the chat room UIKit will also change accordingly . The default value is 350/360.0.
    public static var errorHue: CGFloat = 350/360.0
    
    /// You can change the hue of the base color, and then change the thirteen UIColor objects of the related color series. The UI components that use the relevant color series in the chat room UIKit will also change accordingly. The default value is 203/360.0.
    public static var neutralHue: CGFloat = 203/360.0
    
    /// You can change the hue of the base color, and then change the thirteen UIColor objects of the related color series. The UI components that use the relevant color series in the chat room UIKit will also change accordingly. The default value is 220/360.0
    public static var neutralSpecialHue: CGFloat = 220/360.0
    
    /// You can modify this value to change the value of all gradient end colors.
    public static var gradientEndHue: CGFloat = 233/360.0
    
    /// Replace emoji resource
    /// - Parameters:
    ///   - map: Emoji map.Key is String type .Use as follows sorted keys .
    ///   `["U+1F600", "U+1F604", "U+1F609", "U+1F62E", "U+1F92A", "U+1F60E", "U+1F971", "U+1F974", "U+263A", "U+1F641", "U+1F62D", "U+1F610", "U+1F607", "U+1F62C", "U+1F913", "U+1F633", "U+1F973", "U+1F620", "U+1F644", "U+1F910", "U+1F97A", "U+1F928", "U+1F62B", "U+1F637", "U+1F912", "U+1F631", "U+1F618", "U+1F60D", "U+1F922", "U+1F47F", "U+1F92C", "U+1F621", "U+1F44D", "U+1F44E", "U+1F44F", "U+1F64C", "U+1F91D", "U+1F64F", "U+2764", "U+1F494", "U+1F495", "U+1F4A9", "U+1F48B", "U+2600", "U+1F31C", "U+1F308", "U+2B50", "U+1F31F", "U+1F389", "U+1F490", "U+1F382", "U+1F381"]`
    ///   Value is UIImage instance.
    public static var emojiMap: Dictionary<String,UIImage> = Dictionary<String,UIImage>()
    
    /// language code mirror type.
    public static var targetLanguage: LanguageType = .English
    
    /// ActionSheet data source.
    public static var defaultMessageActions: [ActionSheetItemProtocol] = [ActionSheetItem(title: "barrage_long_press_menu_translate".chatroom.localize, type: .normal,tag: "Translate"),ActionSheetItem(title: "barrage_long_press_menu_delete".chatroom.localize, type: .normal,tag: "Delete"),ActionSheetItem(title: "barrage_long_press_menu_mute".chatroom.localize, type: .normal,tag: "Mute"),ActionSheetItem(title: "barrage_long_press_menu_report".chatroom.localize, type: .destructive,tag: "Report")]
    
    /// ActionSheet row height.
    public static var actionSheetRowHeight: CGFloat = 56
    
    /// Gift list `GiftEntityCell` cell's gift image view placeholder image.
    public static var giftPlaceHolder: UIImage? = UIImage(systemName: "gift")
    
    /// `ChatBarrageCell` avatar image view placeholder image.
    public static var avatarPlaceHolder: UIImage? = UIImage(named: "default_avatar", in: .chatroomBundle, with: nil)
    
    /// `ChatBarrageCell` user level image view placeholder image.
    public static var userIdentifyPlaceHolder: UIImage? = nil
    
    /// `ChatInputBar` Input box height limit.
    public static var maxInputHeight: CGFloat = 88
    
    /// `ChatInputBar` placeholder text.
    public static var inputPlaceHolder = "Aa"
    
    /// `ChatInputBar` corner radius.
    public static var inputBarCorner: CornerRadius = .medium
    
    /// `ChatBarrageCell` avatar image view corner radius.
    public static var avatarRadius: CornerRadius = .large
    
    /// `ChatBarrageCell` default height.
    public static var giftBarrageRowHeight: CGFloat = 64
    
    /// You can set label for report types.
    public static var reportTags: [String] = ["violation_reason_1".chatroom.localize,"violation_reason_2".chatroom.localize,"violation_reason_3".chatroom.localize,"violation_reason_5".chatroom.localize,"violation_reason_5".chatroom.localize,"violation_reason_6".chatroom.localize,"violation_reason_7".chatroom.localize,"violation_reason_8".chatroom.localize,"violation_reason_9".chatroom.localize]
}

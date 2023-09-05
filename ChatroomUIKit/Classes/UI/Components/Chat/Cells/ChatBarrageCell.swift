//
//  ChatBarrageCell.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/5.
//

import UIKit

@objc public enum ChatBarrageCellStyle: UInt {
    case all = 1
    case excludeTime
    case excludeLevel
    case excludeAvatar
    case excludeTimeAndLevel
    case excludeTimeAndAvatar
    case excludeLevelAndAvatar
}

@objc public protocol ChatEntityProtocol: NSObjectProtocol {
    
    var message: ChatMessage {set get}
    
    var attributeText: NSAttributedString {set get}
    
    var user: UserInfoProtocol {set get}
    
    var height: CGFloat {set get}
    
    var width: CGFloat {set get}
}


@objcMembers open class ChatBarrageCell: UITableViewCell {
    
    private var style: ChatBarrageCellStyle = .all

    public lazy var container: UIView = {
        UIView(frame: CGRect(x: 15, y: 6, width: self.contentView.frame.width - 30, height: self.frame.height - 6)).backgroundColor( UIColor.theme.barrageLightColor2)
    }()
    
    lazy var time: UILabel = {
        UILabel(frame: CGRect(x: 10, y: 7, width: 40, height: 18)).font(UIFont.theme.bodyMedium).textColor(UIColor.theme.secondaryColor8).textAlignment(.center)
    }()
    
    lazy var userIdentify: ImageView = {
        var originX = 4
        switch self.style {
        case .all:
            originX += Int(self.time.frame.maxX)
        case .excludeTimeAndAvatar,.excludeTime:
            originX = originX
        default:
            break
        }
        return ImageView(frame: CGRect(x: originX, y: 5, width: 18, height: 18)).backgroundColor(.clear)
    }()
    
    lazy var avatar: ImageView = {
        var originX = 4
        switch self.style {
        case .all,.excludeTime:
            originX += Int(self.userIdentify.frame.maxX)
        case .excludeLevel:
            originX += Int(self.time.frame.maxX)
        case .excludeTimeAndLevel:
            originX = originX
        default:
            break
        }
        return ImageView(frame: CGRect(x: originX, y: 5, width: 18, height: 18)).backgroundColor(.clear)
    }()

    public lazy var content: UILabel = {
        var originX = 4
        switch self.style {
        case .all,.excludeLevel,.excludeTimeAndLevel,.excludeTime:
            originX += Int(self.avatar.frame.maxX)
        case .excludeTimeAndAvatar,.excludeAvatar:
            originX += Int(self.userIdentify.frame.maxX)
        case .excludeLevelAndAvatar:
            originX += Int(self.time.frame.maxX)
        default:
            break
        }
        return UILabel(frame: CGRect(x: 10, y: 7, width: self.container.frame.width - 20, height: self.container.frame.height - 18)).backgroundColor(.clear).numberOfLines(0).lineBreakMode(.byCharWrapping)
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }
    
    @objc required public convenience init(barrageStyle: ChatBarrageCellStyle, reuseIdentifier: String?) {
        self.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.style = style
        self.contentView.addSubview(self.container)
        switch style {
        case .all:
            self.container.addSubViews([self.time,self.userIdentify,self.avatar,self.content])
        case .excludeTime:
            self.container.addSubViews([self.userIdentify,self.avatar,self.content])
        case .excludeLevel:
            self.container.addSubViews([self.time,self.avatar,self.content])
        case .excludeAvatar:
            self.container.addSubViews([self.time,self.userIdentify,self.content])
        case .excludeTimeAndLevel:
            self.container.addSubViews([self.avatar,self.content])
        case .excludeTimeAndAvatar:
            self.container.addSubViews([self.userIdentify,self.content])
        case .excludeLevelAndAvatar:
            self.container.addSubViews([self.time,self.content])
        default:
            break
        }
        Theme.registerSwitchThemeViews(view: self)
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    /// Description 刷新渲染聊天弹幕的实体，内部包含高度宽度以及富文本缓存
    /// - Parameter chat: 实体对象
    @objc public func refresh(chat: ChatEntityProtocol) {
        self.container.frame = CGRect(x: 15, y: 6, width: chat.width + 30, height: chat.height - 6)
        self.content.attributedText = chat.attributeText
        self.content.preferredMaxLayoutWidth =  self.container.frame.width - 24
        self.content.frame = CGRect(x: 12, y: 7, width:  self.container.frame.width - 24, height:  self.container.frame.height - 16)
    }

}


extension ChatBarrageCell: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.container.backgroundColor(style == .dark ? UIColor.theme.barrageLightColor2:UIColor.theme.barrageDarkColor1)
    }
    
    public func switchHues(hues: [CGFloat]) {
        UIColor.ColorTheme.switchHues(hues: hues)
        self.switchTheme(style: .dark)
    }
}
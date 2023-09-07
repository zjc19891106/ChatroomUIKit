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

@objc open class ChatEntity: NSObject {
    
    lazy public var message: ChatMessage = ChatMessage()
    
    lazy public var showTime: String = {
        let date = Date(timeIntervalSince1970: Double(self.message.timestamp)/1000)
        return date.chatroom.dateString("HH:mm")
    }()
    
    lazy public var attributeText: NSAttributedString = self.convertAttribute()
        
    lazy public var height: CGFloat =  UILabel(frame: CGRect(x: 0, y: 0, width: chatViewWidth - 54, height: 15)).numberOfLines(0).lineBreakMode(.byWordWrapping).attributedText(self.attributeText).sizeThatFits(CGSize(width: chatViewWidth - 54, height: 9999)).height + 26
    
    lazy public var width: CGFloat = UILabel(frame: CGRect(x: 0, y: 0, width: chatViewWidth - 54, height: 15)).numberOfLines(0).lineBreakMode(.byWordWrapping).attributedText(self.attributeText).sizeThatFits(CGSize(width: chatViewWidth - 54, height: 9999)).width
        
    func convertAttribute() -> NSAttributedString {
        var text = NSMutableAttributedString {
            AttributedText((self.message.user?.nickName ?? "") + " : ").foregroundColor(Color.theme.primaryColor8).font(UIFont.theme.labelMedium).paragraphStyle(self.paragraphStyle())
            AttributedText(self.message.text).foregroundColor(Color.theme.neutralColor98).font(UIFont.theme.bodyMedium).paragraphStyle(self.paragraphStyle())
        }
        let string = self.message.text as NSString
        for symbol in ChatEmojiConvertor.shared.emojis {
            if string.range(of: symbol).location != NSNotFound {
                let ranges = self.message.text.chatroom.rangesOfString(symbol)
                text = ChatEmojiConvertor.shared.convertEmoji(input: text, ranges: ranges, symbol: symbol)
            }
        }
        return text
    }
    
    func paragraphStyle() -> NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = self.firstLineHeadIndent()
        paragraphStyle.lineHeightMultiple = 1.08
        return paragraphStyle
    }
    
    func firstLineHeadIndent() -> CGFloat {
        var distance:CGFloat = 0
        switch Appearance.barrageCellStyle {
        case .all: distance = 88
        case .excludeTime: distance = 48
        case .excludeLevelAndAvatar: distance = 44
        case .excludeAvatar,.excludeLevel: distance = 62
        case .excludeTimeAndLevel,.excludeTimeAndAvatar: distance = 26
        }
        return distance
    }
}

extension ChatMessage {
    var user: User? {
        ChatroomContext.shared?.usersMap?[from]
    }
    var text: String {
        (self.body as? ChatTextMessageBody)?.text ?? ""
    }
}


@objcMembers open class ChatBarrageCell: UITableViewCell {
    
    private var style: ChatBarrageCellStyle = Appearance.barrageCellStyle

    public lazy var container: UIView = {
        UIView(frame: CGRect(x: 15, y: 6, width: self.contentView.frame.width - 30, height: self.frame.height - 6)).backgroundColor( UIColor.theme.barrageLightColor2).cornerRadius(.small)
    }()
    
    lazy var time: UILabel = {
        UILabel(frame: CGRect(x: 10, y: 11, width: 40, height: 18)).font(UIFont.theme.bodyMedium).textColor(UIColor.theme.secondaryColor8).textAlignment(.center).backgroundColor(.clear)
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
        return ImageView(frame: CGRect(x: originX, y: 10, width: 18, height: 18)).backgroundColor(.clear).cornerRadius(Appearance.avatarRadius)
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
        return ImageView(frame: CGRect(x: originX, y: 10, width: 18, height: 18)).backgroundColor(.clear).cornerRadius(Appearance.avatarRadius)
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
        self.style = barrageStyle
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
    @objc public func refresh(chat: ChatEntity) {
        self.time.text = chat.showTime
        self.userIdentify.image(with: chat.message.user?.identify ?? "", placeHolder: Appearance.userIdentifyPlaceHolder)
        self.avatar.image(with: chat.message.user?.avatarURL ?? "", placeHolder: Appearance.avatarPlaceHolder)
        self.container.frame = CGRect(x: 15, y: 6, width: chat.width + 30, height: chat.height - 6)
        self.content.attributedText = chat.attributeText
        self.content.preferredMaxLayoutWidth =  self.container.frame.width - 24
        self.content.frame = CGRect(x: self.content.frame.minX, y: self.content.frame.minY, width:  self.container.frame.width - 24, height:  self.container.frame.height - 16)
    }
}


extension ChatBarrageCell: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.container.backgroundColor(style == .dark ? UIColor.theme.barrageLightColor2:UIColor.theme.barrageDarkColor1)
    }
    
    public func switchHues() {
        self.switchTheme(style: .dark)
    }
}

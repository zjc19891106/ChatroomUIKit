//
//  ChatBarrageCell.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/5.
//

import UIKit

public struct ChatBarrageCellStyle: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    private static let time = ChatBarrageCellStyle(rawValue: 1 << 0)
    private static let level = ChatBarrageCellStyle(rawValue: 1 << 1)
    private static let avatar = ChatBarrageCellStyle(rawValue: 1 << 2)
    private static let name = ChatBarrageCellStyle(rawValue: 1 << 3)
    private static let content = ChatBarrageCellStyle(rawValue: 1 << 4)
    
    
    public static let all: ChatBarrageCellStyle = [.time,.level,.avatar,.name,.content]
    public static let multiLabel: ChatBarrageCellStyle = [.title, .subTitle]
    public static let singleLabelWithDetail: ChatBarrageCellStyle = [.title, .detail]
    public static let singleLabelWithBadgeAndArrow: ChatBarrageCellStyle = [.title, .badge, .arrow]
    public static let multiLabelWithArrow: ChatBarrageCellStyle = [.title, .subTitle, .arrow]
    public static let singleLabelWithDetailAndArrow: ChatBarrageCellStyle = [.title, .detail, .arrow]
    public static let singleLabelWithSwitch: ChatBarrageCellStyle = [.title, .uiswitch]
    public static let multiLabelWithSwitch: ChatBarrageCellStyle = [.title, .subTitle, .uiswitch]
}


class ChatBarrageCell: UITableViewCell {

    public lazy var container: UIView = {
        UIView(frame: CGRect(x: 15, y: 6, width: self.contentView.frame.width - 30, height: self.frame.height - 6)).backgroundColor( UIColor.theme.barrageLightColor2)
    }()

    public lazy var content: UILabel = {
        UILabel(frame: CGRect(x: 10, y: 7, width: self.container.frame.width - 20, height: self.container.frame.height - 18)).backgroundColor(.clear).numberOfLines(0).lineBreakMode(.byCharWrapping)
    }()

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    /// Description 刷新渲染聊天弹幕的实体，内部包含高度宽度以及富文本缓存
    /// - Parameter chat: 实体对象
    @objc public func refresh(chat: AUIChatEntity) {
        self.container.frame = CGRect(x: 15, y: 6, width: chat.width! + 30, height: chat.height! - 6)
        self.content.attributedText = chat.attributeContent
        self.content.preferredMaxLayoutWidth =  self.container.frame.width - 24
        self.content.frame = CGRect(x: 12, y: 7, width:  self.container.frame.width - 24, height:  self.container.frame.height - 16)
        if chat.joined ?? false {
            self.container.layerThemeProperties("Barrage.containerLayerColor", "Barrage.containerLayerWidth")
        } else {
            self.container.layerProperties(.clear, 0)
        }
        
    }

}

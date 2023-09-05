//
//  BottomItemCell.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/5.
//

import UIKit

@objc public protocol ChatBottomItemProtocol: NSObjectProtocol {
    var showRedDot: Bool {set get}
    
    var selected: Bool {set get}
    
    var selectedImage: UIImage? {set get}
    
    var normalImage: UIImage? {set get}
    
    var type: Int {set get}

}

@objcMembers open class ChatBottomItemCell: UICollectionViewCell {

    lazy var container: UIImageView = {
        UIImageView(frame: CGRect(x: 0, y: 0, width: self.contentView.frame.width, height: self.contentView.frame.height)).contentMode(.scaleAspectFit).backgroundColor(UIColor.theme.barrageLightColor2).cornerRadius(self.contentView.frame.height / 2.0)
    }()

    lazy var icon: UIImageView = {
        UIImageView(frame: CGRect(x: 0, y: 0, width: self.contentView.frame.width, height: self.contentView.frame.height)).contentMode(.scaleAspectFill).backgroundColor(.clear)
    }()

    let redDot = UIView().backgroundColor(.red).cornerRadius(3)

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.contentView.addSubViews([self.container,self.redDot,self.icon])
        Theme.registerSwitchThemeViews(view: self)
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        let r = contentView.frame.width / 2.0
        self.container.cornerRadius(r)
        let length = CGFloat(ceilf(Float(r) / sqrt(2)))
        self.redDot.frame = CGRect(x: frame.width / 2.0 + length, y: contentView.frame.height / 2.0 - length, width: 6, height: 6)
        self.icon.frame = CGRect(x: 7, y: 7, width: contentView.frame.width - 14, height: contentView.frame.height - 14)
    }
    
    func refresh(item: ChatBottomItemProtocol) {
        self.icon.image = item.selected ? item.selectedImage:item.normalImage
        self.redDot.isHidden = item.showRedDot
    }

}

extension ChatBottomItemCell: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.container.backgroundColor(style == .dark ? UIColor.theme.barrageLightColor2:UIColor.theme.barrageDarkColor1)
    }
    
    public func switchHues(hues: [CGFloat]) {
        UIColor.ColorTheme.switchHues(hues: hues)
        self.switchTheme(style: .dark)
    }
}

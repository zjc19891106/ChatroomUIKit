//
//  GiftEntityCell.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/1.
//

import UIKit

/**
 A UICollectionViewCell subclass that displays a gift entity with an icon, name, and price. It also has a "Send" button that triggers a callback when tapped.
 
 - Author: GitHub Copilot
 - Version: 1.0.0
 - Since: 2021-10-15
 */
@objcMembers open class GiftEntityCell: UICollectionViewCell {
    
    private var gift: GiftEntityProtocol?
   
    public var sendCallback: ((GiftEntityProtocol?)->Void)?
    

    lazy var cover: UIView = {
        UIView(frame:CGRect(x: 1, y: 5, width: self.contentView.frame.width-2, height: self.contentView.frame.height - 5)).cornerRadius(.small).layerProperties(UIColor.theme.primaryColor5, 1).backgroundColor(UIColor.theme.primaryColor9)
    }()
    
    lazy var send: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 0, y: self.cover.frame.height-28, width: self.cover.frame.width, height: 28)).backgroundColor(UIColor.theme.primaryColor5).title("Send".chatroom.localize, .normal).textColor(UIColor.theme.neutralColor98, .normal).font(UIFont.theme.labelMedium).addTargetFor(self, action: #selector(sendAction), for: .touchUpInside).cornerRadius(.small, [.bottomLeft,.bottomRight], .clear, 0)
    }()

    lazy var icon: ImageView = {
        ImageView(frame: CGRect(x: self.contentView.frame.width / 2.0 - 24, y: 16.5, width: 48, height: 48)).contentMode(.scaleAspectFit)
    }()

    lazy var name: UILabel = {
        UILabel(frame: CGRect(x: 0, y: self.icon.frame.maxY + 4, width: self.contentView.frame.width, height: 18)).textAlignment(.center).font(UIFont.theme.labelMedium).textColor(UIColor.theme.neutralColor1).backgroundColor(.clear)
    }()

    lazy var displayValue: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 0, y: self.name.frame.maxY + 1, width: self.contentView.frame.width, height: 15)).font(UIFont.theme.labelExtraSmall).textColor(UIColor.theme.neutralColor5, .normal).isUserInteractionEnabled(false).backgroundColor(.clear)
    }()

    override required public init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .clear
        self.contentView.addSubViews([self.cover, self.icon, self.name, self.displayValue])
        self.cover.addSubview(self.send)
        self.displayValue.imageEdgeInsets(UIEdgeInsets(top: self.displayValue.imageEdgeInsets.top, left: -10, bottom: self.displayValue.imageEdgeInsets.bottom, right: self.displayValue.imageEdgeInsets.right))
        
        Theme.registerSwitchThemeViews(view: self)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.icon.frame = CGRect(x: self.contentView.frame.width / 2.0 - 24, y: 16.5, width: 48, height: 48)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc public func refresh(item: GiftEntityProtocol?) {
        self.gift = item
        self.contentView.isHidden = (item == nil)

        let url = self.ossPictureCrop(url: item?.giftIcon ?? "")
        self.icon.image(with: url, placeHolder: Appearance.giftPlaceHolder)
        self.name.text = item?.giftName
        self.displayValue.setImage(UIImage(named: "dollagora", in: .chatroomBundle, with: nil), for: .normal)
        self.displayValue.setTitle(item?.giftPrice ?? "100", for: .normal)
        self.cover.isHidden = !(item?.selected ?? false)
        self.displayValue.frame = CGRect(x: 0, y: item!.selected ? self.icon.frame.maxY + 4:self.name.frame.maxY + 1, width: self.contentView.frame.width, height: 15)
        self.name.isHidden = item?.selected ?? false
    }
    
    @objc private func sendAction() {
        if self.gift?.selected ?? false == true {
            self.sendCallback?(self.gift)
        }
    }
    
    func ossPictureCrop(url: String) -> String {
        var text = url
        if text.contains("?") {
            text += "x-oss-process=image/resize,w_\(Int(UIScreen.main.scale*self.icon.frame.width)),h_\(Int(UIScreen.main.scale*self.icon.frame.height))"
        } else {
            text += "?x-oss-process=image/resize,w_\(Int(UIScreen.main.scale*self.icon.frame.width)),h_\(Int(UIScreen.main.scale*self.icon.frame.height))"
        }
        return text
    }
}

extension GiftEntityCell: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.cover.layerProperties(style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5, 1)
        self.send.backgroundColor(style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5)
        self.name.textColor(style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1)
        self.displayValue.textColor(style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5, .normal)
    }
    
    public func switchHues() {
        self.switchTheme(style: .light)
    }
    
    
}


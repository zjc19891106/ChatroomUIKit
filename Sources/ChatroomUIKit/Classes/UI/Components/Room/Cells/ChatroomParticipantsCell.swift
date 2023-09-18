//
//  ChatroomParticipantsCell.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/8.
//

import UIKit

@objc open class ChatroomParticipantsCell: UITableViewCell {
    
    @objc public var moreClosure: ((UserInfoProtocol) -> Void)?
    
    private var moreImage = UIImage(named: "more", in: .chatroomBundle, with: nil)

    private var user: UserInfoProtocol?
    
    lazy var userLevel: ImageView = {
        ImageView(frame: CGRect(x: 12, y: (self.contentView.frame.height-26)/2, width: 26, height: 26)).backgroundColor(.clear).contentMode(.scaleAspectFit).cornerRadius(Appearance.avatarRadius)
    }()
    
    lazy var userAvatar: ImageView = {
        ImageView(frame: CGRect(x: self.userLevel.frame.maxX+12, y: (self.contentView.frame.height-40)/2, width: 40, height: 40)).backgroundColor(.clear).contentMode(.scaleAspectFit).cornerRadius(Appearance.avatarRadius)
    }()
    
    lazy var userName: UILabel = {
        UILabel(frame: CGRect(x: self.userAvatar.frame.maxX+12, y: self.userAvatar.frame.minY, width: self.contentView.frame.width-self.userAvatar.frame.maxX-36-28, height: 20)).textColor(UIColor.theme.neutralColor5).font(UIFont.theme.labelLarge).backgroundColor(.clear)
    }()

    lazy var userDetail: UILabel = {
        UILabel(frame: CGRect(x: self.userAvatar.frame.maxX+12, y: self.userAvatar.frame.maxY-18, width: self.contentView.frame.width-self.userAvatar.frame.maxX-36-28, height: 18)).textColor(UIColor.theme.neutralColor1).font(UIFont.theme.bodyMedium).backgroundColor(.clear)
    }()
    
    lazy var more: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.contentView.frame.width-40, y: (self.contentView.frame.height-28)/2.0, width: 28, height: 28)).backgroundColor(.clear).image(self.moreImage, .normal).addTargetFor(self, action: #selector(moreAction), for: .touchUpInside)
    }()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor(.clear)
        self.contentView.backgroundColor(.clear)
        self.contentView.addSubViews([self.userLevel,self.userAvatar,self.userName,self.userDetail,self.more])
        Theme.registerSwitchThemeViews(view: self)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        self.more.frame = CGRect(x: self.contentView.frame.width-40, y: (self.contentView.frame.height-28)/2.0, width: 28, height: 28)
    }
    
    @objc public func refresh(user: UserInfoProtocol) {
        self.user = user
        self.userLevel.image(with: user.identify, placeHolder: Appearance.userIdentifyPlaceHolder)
        self.userAvatar.image(with: user.avatarURL, placeHolder: Appearance.avatarPlaceHolder)
        self.userName.text = user.nickName
        if self.userDetail.text == nil {
            self.userName.frame = CGRect(x: self.userAvatar.frame.maxX+12, y: self.userAvatar.frame.minY+10, width: self.contentView.frame.width-self.userAvatar.frame.maxX-36-28, height: 20)
        } else {
            self.userName.frame = CGRect(x: self.userAvatar.frame.maxX+12, y: self.userAvatar.frame.minY, width: self.contentView.frame.width-self.userAvatar.frame.maxX-36-28, height: 20)
        }
    }
    
    @objc private func moreAction() {
        if let user = self.user {
            self.moreClosure?(user)
        }
    }
}

extension ChatroomParticipantsCell: ThemeSwitchProtocol {
    
    public func switchTheme(style: ThemeStyle) {
        self.moreImage?.withTintColor(style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5, renderingMode: .automatic)
        self.more.setImage(self.moreImage, for: .normal)
    }
    
    public func switchHues() {
        self.switchTheme(style: .light)
    }
    
    
}

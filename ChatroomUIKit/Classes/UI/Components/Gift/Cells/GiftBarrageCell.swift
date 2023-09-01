//
//  GiftBarrageCell.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/1.
//

import UIKit

@objcMembers public class GiftBarrageCell: UITableViewCell {

    var gift: GiftEntityProtocol?
    
    lazy var container: UIToolbar = {
        UIToolbar(frame: CGRect(x: 0, y: 5, width: self.contentView.frame.width, height: self.contentView.frame.height - 10)).backgroundColor(.clear).isUserInteractionEnabled(false)
    }()
    
    lazy var avatar: ImageView = ImageView(frame: CGRect(x: 5, y: 5, width: self.frame.width / 5.0, height: self.frame.width / 5.0)).contentMode(.scaleAspectFit)
    
    lazy var userName: UILabel = {
        UILabel(frame: CGRect(x: self.avatar.frame.maxX + 6, y: 8, width: self.frame.width / 5.0 * 2 - 12, height: 15)).font(UIFont.theme.headlineExtraSmall).textColor(UIColor.theme.neutralColor100)
    }()
    
    lazy var giftName: UILabel = {
        UILabel(frame: CGRect(x: self.avatar.frame.maxX + 6, y: self.userName.frame.maxY, width: self.frame.width / 5.0 * 2 - 12, height: 15)).font(UIFont.theme.bodySmall).textColor(UIColor.theme.neutralColor100)
    }()
    
    lazy var giftIcon: ImageView = {
        ImageView(frame: CGRect(x: self.frame.width / 5.0 * 3, y: 0, width: self.frame.width / 5.0, height: self.contentView.frame.height)).contentMode(.scaleAspectFit)
    }()
    
    lazy var giftNumbers: UILabel = {
        UILabel(frame: CGRect(x: self.frame.width / 5.0 * 4 + 8, y: 10, width: self.frame.width / 5.0 - 16, height: self.frame.height - 20)).font(UIFont.theme.giftNumberFont).textColor(UIColor.theme.neutralColor100)
    }()

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.isUserInteractionEnabled = false
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.addSubview(self.container)
        self.container.addSubViews([self.avatar, self.userName, self.giftName, self.giftIcon, self.giftNumbers])
        self.container.barStyle = .default
        self.container.isTranslucent = false
        self.container.isOpaque = false
    }
    

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        self.container.frame = CGRect(x: 0, y: 5, width: contentView.frame.width, height: contentView.frame.height - 10)
        self.container.createGradient([], [CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 1)],[0,1])
        self.container.cornerRadius(self.container.frame.height/2.0)
        self.avatar.frame = CGRect(x: 5, y: 5, width: self.container.frame.height - 10, height: self.container.frame.height - 10)
        self.avatar.cornerRadius((self.container.frame.height - 10) / 2.0)
        self.userName.frame = CGRect(x: self.avatar.frame.maxX + 6, y: self.container.frame.height/2.0 - 15, width: frame.width / 5.0 * 2 - 12, height: 15)
        self.giftName.frame = CGRect(x: self.avatar.frame.maxX + 6, y: self.container.frame.height/2.0 , width: frame.width / 5.0 * 2 - 12, height: 15)
        self.giftIcon.frame = CGRect(x: frame.width / 5.0 * 3, y: 0, width: self.container.frame.height, height: self.container.frame.height)
        self.giftNumbers.frame = CGRect(x: self.giftIcon.frame.maxX + 5, y: 5, width: self.container.frame.width - self.giftIcon.frame.maxX - 5, height: self.container.frame.height - 5)
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        super.hitTest(point, with: event)
    }

    @objc public func refresh(item: GiftEntityProtocol) {
        if self.gift == nil {
            self.gift = item
        }
        if let avatarURL = item.sendUser?.avatarURL {
            self.avatar.image(with:avatarURL, placeHolder: UIImage(named: "", in: .chatroomBundle, with: nil))
        }
        
        self.userName.text = item.sendUser?.nickName
        self.giftName.text = "Sent ".chatroom.localize + (item.giftName)
        self.giftIcon.image(with: item.giftIcon, placeHolder: nil)
        self.giftNumbers.text = "X \(item.giftCount)"
    }


}


extension GiftBarrageCell: ThemeSwitchProtocol {
    public func switchHues(hues: [CGFloat]) {
        
    }
    
    public func switchTheme(style: ThemeStyle) {
        if style == .dark {
//            self.container.barTintColor = UIColor(red: <#T##CGFloat#>, green: <#T##CGFloat#>, blue: <#T##CGFloat#>, alpha: <#T##CGFloat#>)
        } else {
            
        }
    }
    
    
}

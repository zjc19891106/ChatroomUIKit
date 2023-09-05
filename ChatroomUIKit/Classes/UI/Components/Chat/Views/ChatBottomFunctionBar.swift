//
//  ChatBottomFunctionBar.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/5.
//

import UIKit

class ChatBottomFunctionBar: UIView {

    public var raiseKeyboard: (() -> Void)?
    
    public var actionClosure: ((ChatBottomItemProtocol) -> Void)?

    public var datas = [ChatBottomItemProtocol]()

    public lazy var chatRaiser: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 15, y: 5, width: (110 / 375.0) * self.frame.width, height: self.frame.height - 10)).backgroundColor(UIColor.theme.barrageLightColor2).cornerRadius((self.frame.height - 10) / 2.0).font(.systemFont(ofSize: 12, weight: .regular)).textColor(UIColor(white: 1, alpha: 0.8), .normal).addTargetFor(self, action: #selector(raiseAction), for: .touchUpInside)
    }()

    lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.frame.height - 10, height: self.frame.height - 10)
        layout.minimumInteritemSpacing = 8
        layout.scrollDirection = .horizontal
        return layout
    }()

    public lazy var toolBar: UICollectionView = {
        UICollectionView(frame: CGRect(x: self.frame.width - (40 * CGFloat(self.datas.count)) - (CGFloat(self.datas.count) - 1) * 8 - 25 - 10, y: 0, width: 40 * CGFloat(self.datas.count) + (CGFloat(self.datas.count) - 1) * 8 + 25, height: self.frame.height), collectionViewLayout: self.flowLayout).delegate(self).dataSource(self).backgroundColor(.clear).registerCell(ChatBottomItemCell.self, forCellReuseIdentifier: "ChatBottomItemCell").showsVerticalScrollIndicator(false).showsHorizontalScrollIndicator(false)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public convenience init(frame: CGRect, datas: [ChatBottomItemProtocol], hiddenChat: Bool) {
        self.init(frame: frame)
        self.datas = datas
        self.chatRaiser.isHidden = hiddenChat
        self.addSubViews([self.chatRaiser, self.toolBar])
        self.chatRaiser.setImage(UIImage(named: "chatraise",in: .chatroomBundle,compatibleWith: nil), for: .normal)
        self.chatRaiser.setTitle(" " + "Let's Chat!".chatroom.localize, for: .normal)
        self.chatRaiser.titleEdgeInsets = UIEdgeInsets(top: self.chatRaiser.titleEdgeInsets.top, left: 10, bottom: self.chatRaiser.titleEdgeInsets.bottom, right: 10)
        self.chatRaiser.imageEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 80)
        self.chatRaiser.contentHorizontalAlignment = .left
        self.backgroundColor = .clear
        Theme.registerSwitchThemeViews(view: self)
    }
    
    @objc public func refreshToolBar(datas: [ChatBottomItemProtocol]) {
        self.datas.removeAll()
        self.datas = datas
        self.toolBar.frame = CGRect(x: self.frame.width - (40 * CGFloat(self.datas.count)) - (CGFloat(self.datas.count) - 1) * 8 - 25 - 10, y: 0, width: 40 * CGFloat(self.datas.count) + (CGFloat(self.datas.count) - 1) * 8 + 25, height: self.frame.height)
        self.toolBar.reloadData()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension ChatBottomFunctionBar: UICollectionViewDelegate, UICollectionViewDataSource {
    
    @objc func raiseAction() {
        self.raiseKeyboard?()
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.datas.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChatBottomItemCell", for: indexPath) as? ChatBottomItemCell
        if let entity = self.datas[safe:indexPath.row] {
            cell?.refresh(item: entity)
        }
        return cell ?? ChatBottomItemCell()
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let entity = self.datas[safe:indexPath.row] else { return }
        self.actionClosure?(entity)
        self.toolBar.reloadItems(at: [indexPath])
    }
}

extension ChatBottomFunctionBar: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.chatRaiser.backgroundColor(style == .dark ? UIColor.theme.barrageLightColor2:UIColor.theme.barrageDarkColor9)
        self.toolBar.reloadData()
    }
    
    public func switchHues(hues: [CGFloat]) {
        UIColor.ColorTheme.switchHues(hues: hues)
        self.switchTheme(style: .dark)
    }
    
    
}

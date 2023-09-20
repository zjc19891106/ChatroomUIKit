//
//  ChatBottomFunctionBar.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/5.
//

import UIKit

/// ChatBottomFunctionBar‘s driver.
@objc public protocol IChatBottomFunctionBarDriver: NSObjectProtocol {
    
    /// You can call the method update item select state.
    /// - Parameters:
    ///   - index: Index
    ///   - select: `Bool`select value
    func updateItemSelectState(index: UInt, select: Bool)
    
    /// You can call the method update item red dot show or hidden.
    /// - Parameters:
    ///   - index: Index
    ///   - showRedDot: `Bool` showRedDot  value
    func updateItemRedDot(index: UInt, showRedDot: Bool)
    
    /// You can call then method update ChatBottomFunctionBar‘s data source.
    /// - Parameter items: `Array<ChatBottomItemProtocol>`
    func updateDatas(items: [ChatBottomItemProtocol])
}

/// ChatBottomFunctionBar actions delegate.
@objc public protocol ChatBottomFunctionBarActionEvents: NSObjectProtocol {
    
    /// ChatBottomFunctionBar each item click event.
    /// - Parameter item: ChatBottomItemProtocol
    func onBottomItemClicked(item: ChatBottomItemProtocol)
    
    /// When you tap `button` let's chat callback.
    func onKeyboardWillWakeup()
}

@objcMembers open class ChatBottomFunctionBar: UIView {

    lazy private var eventHandlers: NSHashTable<ChatBottomFunctionBarActionEvents> = NSHashTable<ChatBottomFunctionBarActionEvents>.weakObjects()
    
    
    /// Add UI action handler.
    /// - Parameter actionHandler: ``ChatBottomFunctionBarActionEvents``
    public func addActionHandler(actionHandler: ChatBottomFunctionBarActionEvents) {
        if self.eventHandlers.contains(actionHandler) {
            return
        }
        self.eventHandlers.add(actionHandler)
    }
    
    /// Remove UI action handler.
    /// - Parameter actionHandler: ``ChatBottomFunctionBarActionEvents``
    public func removeEventHandler(actionHandler: ChatBottomFunctionBarActionEvents) {
        self.eventHandlers.remove(actionHandler)
    }
    
    private var datas = [ChatBottomItemProtocol]()

    lazy var chatRaiser: UIButton = {
        UIButton(type: .custom).frame(.zero).backgroundColor(UIColor.theme.barrageLightColor2).cornerRadius((self.frame.height - 10) / 2.0).font(.systemFont(ofSize: 12, weight: .regular)).textColor(UIColor(white: 1, alpha: 0.8), .normal).addTargetFor(self, action: #selector(raiseAction), for: .touchUpInside).backgroundColor(UIColor.theme.barrageDarkColor1)
    }()

    lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.frame.height - 10, height: self.frame.height - 10)
        layout.minimumInteritemSpacing = 8
        layout.scrollDirection = .horizontal
        return layout
    }()

    lazy var toolBar: UICollectionView = {
        UICollectionView(frame: .zero, collectionViewLayout: self.flowLayout).delegate(self).dataSource(self).backgroundColor(.clear).registerCell(ChatBottomItemCell.self, forCellReuseIdentifier: "ChatBottomItemCell").showsVerticalScrollIndicator(false).showsHorizontalScrollIndicator(false)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    /// ChatBottomBar init method
    /// - Parameters:
    ///   - frame: CGRect
    ///   - datas: Array<ChatBottomItemProtocol>
    ///   - hiddenChat: Whether to hide the evoke keyboard button
    @objc required public convenience init(frame: CGRect, datas: [ChatBottomItemProtocol] = [], hiddenChat: Bool = false) {
        self.init(frame: frame)
        self.datas = datas
        self.chatRaiser.isHidden = hiddenChat
        self.addSubViews([self.chatRaiser, self.toolBar])
        self.refreshToolBar(datas: datas)
        self.chatRaiser.setImage(UIImage(named: "chatraise",in: .chatroomBundle,with: nil), for: .normal)
        self.chatRaiser.setTitle(" " + "StartChat".chatroom.localize, for: .normal)
        self.chatRaiser.titleEdgeInsets = UIEdgeInsets(top: self.chatRaiser.titleEdgeInsets.top, left: 10, bottom: self.chatRaiser.titleEdgeInsets.bottom, right: 10)
        self.chatRaiser.imageEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 80)
        self.chatRaiser.contentHorizontalAlignment = .left
        self.backgroundColor = .clear
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    private func refreshToolBar(datas: [ChatBottomItemProtocol]) {
        self.datas.removeAll()
        self.datas = datas
        let toolBarWidth = self.frame.width - (40 * CGFloat(self.datas.count)) - (CGFloat(self.datas.count) - 1) * 8 - 32 - 30
        if !self.chatRaiser.isHidden {
            self.chatRaiser.frame = CGRect(x: 15, y: 5, width: 120, height: self.frame.height - 10)
        }
        self.toolBar.frame = CGRect(x: self.frame.width - toolBarWidth, y: 0, width: 40 * CGFloat(self.datas.count) + (CGFloat(self.datas.count) - 1) * 8 + 25, height: self.frame.height)
        self.toolBar.reloadData()
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension ChatBottomFunctionBar: UICollectionViewDelegate, UICollectionViewDataSource {
    
    @objc func raiseAction() {
        for handler in self.eventHandlers.allObjects {
            handler.onKeyboardWillWakeup()
        }
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
        for handler in self.eventHandlers.allObjects {
            handler.onBottomItemClicked(item: entity)
        }
        self.toolBar.reloadItems(at: [indexPath])
    }
}

extension ChatBottomFunctionBar: IChatBottomFunctionBarDriver {
    public func updateItemSelectState(index: UInt, select: Bool) {
        self.datas[safe: Int(index)]?.selected = select
    }
    
    public func updateItemRedDot(index: UInt, showRedDot: Bool) {
        self.datas[safe: Int(index)]?.showRedDot = showRedDot
    }
    
    public func updateDatas(items: [ChatBottomItemProtocol]) {
        self.refreshToolBar(datas: items)
    }
    
}

extension ChatBottomFunctionBar: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.chatRaiser.backgroundColor(style == .dark ? UIColor.theme.barrageLightColor2:UIColor.theme.barrageDarkColor1)
        self.toolBar.reloadData()
    }
    
    public func switchHues() {
        self.switchTheme(style: .dark)
    }
    
    
}

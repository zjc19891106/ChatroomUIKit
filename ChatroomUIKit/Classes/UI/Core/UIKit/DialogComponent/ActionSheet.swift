//
//  ActionSheet.swift
//  Picker
//
//  Created by 朱继超 on 2023/8/28.
//

import UIKit

@objc open class ActionSheet: UIView {
    
    private var style: ThemeStyle = .light
    
    public var items: [ActionSheetItemProtocol] = []
    
    lazy var indicator: UIView = {
        UIView(frame: CGRect(x: self.frame.width/2.0-18, y: 6, width: 36, height: 5)).cornerRadius(2.5).backgroundColor(UIColor.theme.neutralColor8)
    }()
    
    lazy var titleContainer: UILabel = {
        UILabel(frame: CGRect(x: 20, y: self.indicator.frame.maxY+16, width: self.frame.width-40, height: 22)).textColor(UIColor.theme.neutralColor1).font(UIFont.theme.titleMedium).textAlignment(.center)
    }()
    
    lazy var messageContainer: UILabel = {
        UILabel(frame: CGRect(x: 16, y: self.titleContainer.frame.maxY+5, width: self.frame.width-32, height: .greatestFiniteMagnitude)).textColor(UIColor.theme.neutralColor5).font(UIFont.theme.bodyMedium).textAlignment(.center).numberOfLines(5)
    }()
    
    lazy var dividingLine: UIView = {
        UIView(frame: CGRect(x: 16, y: self.messageContainer.frame.maxY+12, width: ScreenWidth-32, height: 0.5)).backgroundColor(UIColor.theme.neutralColor9)
    }()
    
    lazy var menuList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: self.messageContainer.frame.maxY+5, width: self.frame.width, height: CGFloat(Int(Appearance.actionSheetRowHeight)*self.items.count + 8)), style: .plain).delegate(self).dataSource(self).registerCell(ActionSheetCell.self, forCellReuseIdentifier: "ActionSheetCell").rowHeight(Appearance.actionSheetRowHeight).separatorColor(UIColor.theme.neutralColor9).backgroundColor(UIColor.theme.neutralColor95).tableFooterView(UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 8)).backgroundColor(UIColor.theme.neutralColor95)).separatorStyle(.singleLine)
    }()
    
    lazy var cancel: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 0, y: self.frame.height - Appearance.actionSheetRowHeight - BottomBarHeight, width: self.frame.width, height: Appearance.actionSheetRowHeight)).backgroundColor(UIColor.theme.neutralColor98).title("Cancel", .normal).font(UIFont.theme.labelLarge).textColor(UIColor.theme.primaryColor5, .normal).addTargetFor(self, action: #selector(cancelAction), for: .touchUpInside)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @objc public convenience init(items:[ActionSheetItemProtocol],title: String? = nil,message: String? = nil) {
        let messageHeight = (message?.chatroom.sizeWithText(font: UIFont.theme.bodyMedium, size: CGSize(width: ScreenWidth-32, height: ScreenHeight/3.0)).height ?? 0)
        var contentHeight = 11+Int(Appearance.actionSheetRowHeight)*items.count+Int(Appearance.actionSheetRowHeight)+8+Int(BottomBarHeight)
        if messageHeight > 0 {
            contentHeight += (Int(messageHeight)+20)
            if title != nil {
                contentHeight += 43
            }
        } else {
            if title != nil {
                contentHeight += 43
            }
        }
        if CGFloat(contentHeight) > ScreenHeight*(2/3.0) {
            contentHeight = Int(ScreenHeight*(2/3.0))
        }
        self.init(frame: CGRect(x: 0, y: abs(Int(ScreenHeight)-contentHeight), width: Int(ScreenWidth), height: contentHeight))
        self.backgroundColor(UIColor.theme.neutralColor98)
        self.items.append(contentsOf: items)
        if title != nil,message != nil {
            self.titleContainer.text = title
            self.messageContainer.text = message
            self.messageContainer.frame = CGRect(x: 16, y: self.titleContainer.frame.maxY+5, width: self.frame.width-32, height: messageHeight+10)
            self.addSubViews([self.indicator,self.titleContainer,self.messageContainer,self.menuList,self.cancel,self.dividingLine])
        } else {
            if title == nil,message == nil {
                self.menuList.frame = CGRect(x: 0, y: self.indicator.frame.maxY+5, width: self.frame.width, height: self.frame.height-Appearance.actionSheetRowHeight)
                self.addSubViews([self.indicator,self.menuList,self.cancel])
            } else {
                if title == nil {
                    self.messageContainer.text = message
                    self.messageContainer.frame = CGRect(x: 16, y: self.indicator.frame.maxY+5, width: self.frame.width-32, height: messageHeight+10)
                    self.addSubViews([self.indicator,self.messageContainer,self.menuList,self.cancel,self.dividingLine])
                } else {
                    self.titleContainer.text = title
                    self.dividingLine.frame = CGRect(x: 16, y: self.titleContainer.frame.maxY+12, width: ScreenWidth-32, height: 0.5)
                    self.menuList.frame = CGRect(x: 0, y: self.titleContainer.frame.maxY+5, width: self.frame.width, height: CGFloat(Int(Appearance.actionSheetRowHeight)*self.items.count + 8))
                    self.addSubViews([self.indicator,self.titleContainer,self.menuList,self.cancel,self.dividingLine])
                }
            }
        }
        
        Theme.registerSwitchThemeViews(view: self)
    }
    
    @objc private func cancelAction() {
        
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ActionSheet: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.style = style
        self.backgroundColor(style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98)
        self.titleContainer.textColor(style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1)
        self.messageContainer.textColor(style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5)
        self.dividingLine.backgroundColor(style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor9)
        self.cancel.backgroundColor(style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98)
        self.cancel.setTitleColor(style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5, for: .normal)
        self.indicator.backgroundColor(style == .dark ? UIColor.theme.neutralColor3:UIColor.theme.neutralColor8)
        self.menuList.tableFooterView?.backgroundColor(style == .dark ? UIColor.theme.neutralColor0:UIColor.theme.neutralColor95)
        self.menuList.separatorColor(style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor9)
        self.menuList.reloadData()
    }
    
    public func switchHues() {
        self.switchTheme(style: .light)
    }
}

extension ActionSheet: UITableViewDelegate,UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ActionSheetCell") as? ActionSheetCell
        if cell == nil {
            cell = ActionSheetCell(style: .default, reuseIdentifier: "ActionSheetCell")
        }
        cell?.backgroundColor(self.style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98)
        cell?.contentView.backgroundColor(self.style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98)
        let item = self.items[indexPath.row]
        cell?.textLabel?.text = item.title
        cell?.textLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        cell?.textLabel?.textAlignment = item.image == nil ? .center:.left
        cell?.imageView?.image = item.image
        cell?.textLabel?.numberOfLines = 2
        cell?.textLabel?.backgroundColor = .clear
        if self.style == .light {
            cell?.textLabel?.textColor = self.items[indexPath.row].type == .destructive ? UIColor.theme.errorColor5 : UIColor.theme.primaryColor5
        } else {
            cell?.textLabel?.textColor = self.items[indexPath.row].type == .destructive ? UIColor.theme.errorColor6 : UIColor.theme.primaryColor6
        }
        cell?.selectionStyle = .none
        return cell ?? ActionSheetCell()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = self.items[indexPath.row]
        item.action?(item)
    }
    
}

@objc open class ActionSheetCell: UITableViewCell {
    
    
    
}


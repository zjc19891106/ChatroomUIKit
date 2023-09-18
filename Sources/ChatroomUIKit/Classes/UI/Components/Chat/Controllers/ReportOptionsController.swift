//
//  ReportOptionsController.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/12.
//

import UIKit

@objc open class ReportOptionsController: UIViewController {
    
    public private(set) var items: [Bool] = []
    
    public private(set) var reportMessage: ChatMessage = ChatMessage()
    
    public private(set) var selectIndex = 0
    
    lazy var optionsList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 20 - 40 - BottomBarHeight - 20), style: .grouped).separatorStyle(.none).rowHeight(54).tableFooterView(UIView()).delegate(self).dataSource(self).registerCell(ReportOptionCell.self, forCellReuseIdentifier: "ReportOptionCell").backgroundColor(.clear)
    }()
    
    lazy var cancel: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 16, y: self.view.frame.height - 20 - 40 - BottomBarHeight, width: (self.view.frame.width-44)/2.0, height: 40)).layerProperties(UIColor.theme.neutralColor7, 1).textColor(UIColor.theme.neutralColor3, .normal).title("Cancel", .normal).font(UIFont.theme.headlineSmall).cornerRadius(.large).addTargetFor(self, action: #selector(cancelAction), for: .touchUpInside)
    }()
    
    lazy var confirm: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.cancel.frame.maxX+12, y: self.view.frame.height - 20 - 40 - BottomBarHeight, width: (self.view.frame.width-44)/2.0, height: 40)).title("Report", .normal).textColor(UIColor.theme.neutralColor98, .normal).backgroundColor(UIColor.theme.primaryColor5).cornerRadius(.large).addTargetFor(self, action: #selector(report), for: .touchUpInside)
    }()
    
    /// Init method
    /// - Parameter message: Reported message.
    @objc public required convenience init(message: ChatMessage) {
        self.init()
        self.reportMessage = message
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.items = Appearance.reportTags.map({ $0 == "Adult" })
        self.view.backgroundColor(.clear)
        self.view.addSubViews([self.optionsList,self.cancel,self.confirm])
        self.switchTheme(style: Theme.style)
    }

}

extension ReportOptionsController: UITableViewDelegate,UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Violation options".chatroom.localize
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Appearance.reportTags.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ReportOptionCell") as? ReportOptionCell
        if cell == nil {
            cell = ReportOptionCell(style: .default, reuseIdentifier: "ReportOptionCell")
        }
        cell?.selectionStyle = .none
        cell?.refresh(select: self.items[safe: indexPath.row] ?? false,title: Appearance.reportTags[safe: indexPath.row] ?? "")
        return cell ?? ReportOptionCell()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
        self.items.removeAll()
        self.items = Array(repeating: false, count: Appearance.reportTags.count)
        self.items[indexPath.row] = true
        self.selectIndex = indexPath.row
        self.optionsList.reloadData()
    }
    
    @objc private func report() {
        ChatClient.shared().chatManager?.reportMessage(withId: self.reportMessage.messageId, tag: Appearance.reportTags[safe: self.selectIndex] ?? "", reason: "",completion: { error in
            if error != nil {
                UIViewController.currentController?.makeToast(toast: error?.errorDescription ?? "",style: Theme.style == .light ? .light:.dark,duration: 2)
            }
        })
    }
    
    @objc private func cancelAction() {
        self.dismiss(animated: true)
    }
}

extension ReportOptionsController: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.optionsList.reloadData()
    }
    
    public func switchHues() {
        self.switchTheme(style: .light)
    }
    
}
//
//  ReportOptionsController.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/12.
//

import UIKit

@objc open class ReportOptionsController: UIViewController {
    
    private var items: [Bool] = []
    
    lazy var optionsList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 20 - 40 - BottomBarHeight - 20), style: .grouped).separatorStyle(.none).rowHeight(54).tableFooterView(UIView()).delegate(self).dataSource(self).registerCell(ReportOptionCell.self, forCellReuseIdentifier: "ReportOptionCell").backgroundColor(.clear)
    }()
    
    lazy var cancel: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 16, y: self.view.frame.height - 20 - 40 - BottomBarHeight, width: (self.view.frame.width-44)/2.0, height: 40)).layerProperties(UIColor.theme.neutralColor7, 1).textColor(UIColor.theme.neutralColor3, .normal).title("Cancel", .normal).font(UIFont.theme.headlineSmall).cornerRadius(.large)
    }()
    
    lazy var confirm: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.cancel.frame.maxX+12, y: self.view.frame.height - 20 - 40 - BottomBarHeight, width: (self.view.frame.width-44)/2.0, height: 40)).title("Report", .normal).textColor(UIColor.theme.neutralColor98, .normal).backgroundColor(UIColor.theme.primaryColor5).cornerRadius(.large)
    }()
    
    @objc public required convenience init(message: ChatMessage) {
        self.init()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.items = Appearance.reportTags.map({ $0 == "Adult" })
        self.view.backgroundColor(.clear)
        self.view.addSubViews([self.optionsList,self.cancel,self.confirm])
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
        cell?.refresh(select: self.items[safe: indexPath.row] ?? false)
        return cell ?? ReportOptionCell()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
        self.items.removeAll()
        self.items = Array(repeating: false, count: Appearance.reportTags.count)
        self.items[indexPath.row] = true
        self.optionsList.reloadData()
    }
}

//
//  ParticipantsController.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/11.
//

import UIKit

open class ParticipantsController: UITableViewController {
    
    private var roomService = RoomService(roomId: ChatroomContext.shared?.roomId ?? "")
    
    private var users = [UserInfoProtocol]()
    
    private var pageSize: UInt = 15
    
    private var fetchFinish = true
    
    private var muteTab = false
    
    /// Description ParticipantsController init method.
    /// - Parameters:
    ///   - muteTab: `Bool` value
    ///   - moreClosure: Callback,when click more.
    @objc required public convenience init(muteTab:Bool = false,moreClosure: (UserInfoProtocol) -> Void) {
        self.init()
        self.muteTab = muteTab
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorColor(UIColor.theme.neutralColor9)
        self.tableView.tableFooterView(UIView())
        Theme.registerSwitchThemeViews(view: self)
        // Uncomment the following line to preserve selection between presentations
        self.fetchFinish = false
        self.fetchUsers()
    }
    
    func fetchUsers() {
        if self.muteTab {
            self.roomService.fetchMuteUsers(pageSize: self.pageSize) { [weak self] datas, error in
                self?.fetchFinish = true
                if error == nil {
                    self?.users.append(contentsOf: datas ?? [])
                    self?.tableView.reloadData()
                }
            }
        } else {
            self.roomService.fetchParticipants(pageSize: self.pageSize) { [weak self] datas, error in
                self?.fetchFinish = true
                if error == nil {
                    self?.users.append(contentsOf: datas ?? [])
                    self?.tableView.reloadData()
                }
            }
        }
    }

    // MARK: - Table view data source

    open override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.users.count
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ChatroomParticipantsCell", for: indexPath) as? ChatroomParticipantsCell
        if cell == nil {
            cell = ChatroomParticipantsCell(style: .default, reuseIdentifier: "ChatroomParticipantsCell")
        }
        // Configure the cell...
        if let user = self.users[safe: indexPath.row] {
            cell?.refresh(user: user)
        }
        
        cell?.selectionStyle = .none
        return cell ?? ChatroomParticipantsCell()
    }
    
    open override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if UInt(self.users.count)%self.pageSize == 0,self.users.count - 3 == indexPath.row,self.fetchFinish {
            self.fetchFinish = false
            self.fetchUsers()
        }
    }
}

extension ParticipantsController: ThemeSwitchProtocol {
    
    public func switchTheme(style: ThemeStyle) {
        self.tableView.separatorColor(style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor9)
        self.tableView.backgroundColor(style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1)
    }
    
    public func switchHues() {
        self.switchTheme(style: .light)
    }
    
    
}

//
//  ParticipantsController.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/11.
//

import UIKit

/// Chatroom participants list
open class ParticipantsController: UITableViewController {
        
    public private(set) var roomService = RoomService(roomId: ChatroomContext.shared?.roomId ?? "")
    
    public private(set) var users = [UserInfoProtocol]() {
        didSet {
            DispatchQueue.main.async {
                if self.users.count <= 0 {
                    self.tableView.backgroundView = self.empty
                } else {
                    self.tableView.backgroundView = nil
                }
            }
        }
    }
    
    public private(set) var fetchFinish = true
    
    public private(set) var muteTab = false
    
    private var search: SearchViewController?
    
    lazy var loadingView: LoadingView = {
        LoadingView(frame: CGRect(x: self.tableView.frame.width/2.0 - 50, y: self.tableView.frame.height/2.0 - 50, width: 100, height: 100))
    }()
    
    lazy var searchField: SearchBar = {
        SearchBar(frame: CGRect(x: 0, y: 0, width: Appearance.pageContainerConstraintsSize.width, height: 44))
    }()
    
    lazy var empty: EmptyStateView = {
        EmptyStateView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: self.tableView.frame.height),emptyImage: UIImage(named: "empty",in: .chatroomBundle, with: nil))
    }()
    
    /// ParticipantsController init method.
    /// - Parameters:
    ///   - muteTab: `Bool` value,Indicate that is member list or mute list
    ///   - moreClosure: Callback,when click more.
    @objc required public convenience init(muteTab:Bool = false,moreClosure: @escaping (UserInfoProtocol) -> Void) {
        self.init()
        self.muteTab = muteTab
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.tableView.backgroundColor = .clear
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableHeaderView = self.searchField
        self.tableView.registerCell(ComponentsRegister.shared.ChatroomParticipantCell, forCellReuseIdentifier: "ChatroomParticipantsCell")
        self.tableView.rowHeight = Appearance.membersRowHeight
        self.tableView.separatorColor(UIColor.theme.neutralColor9)
        self.tableView.tableFooterView(UIView())
        self.searchField.addActionHandler(handler: self)
        self.tableView.addSubview(self.loadingView)
        Theme.registerSwitchThemeViews(view: self)
        // Uncomment the following line to preserve selection between presentations
        self.fetchFinish = false
        self.fetchUsers()
    }
    
    func fetchUsers() {
        self.loadingView.startAnimating()
        if self.muteTab {
            self.roomService.fetchMuteUsers(pageSize: Appearance.membersPageSize) { [weak self] datas, error in
                DispatchQueue.main.async {
                    self?.loadingView.stopAnimating()
                    self?.fetchFinish = true
                    if error == nil {
                        self?.users.append(contentsOf: datas ?? [])
                        self?.tableView.reloadData()
                    }
                }
            }
        } else {
            self.roomService.fetchParticipants(pageSize: Appearance.membersPageSize) { [weak self] datas, error in
                DispatchQueue.main.async {
                    self?.loadingView.stopAnimating()
                    self?.fetchFinish = true
                    if error == nil {
                        self?.users.append(contentsOf: datas ?? [])
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }

    // MARK: - Table view data source

    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.users.count
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(with: ComponentsRegister.shared.ChatroomParticipantCell, reuseIdentifier: "ChatroomParticipantsCell")
        if cell == nil {
            cell = ComponentsRegister.shared.ChatroomParticipantCell.init(style: .default, reuseIdentifier: "ChatroomParticipantsCell")
        }
        // Configure the cell...
        if let user = self.users[safe: indexPath.row] {
            cell?.refresh(user: user)
        }
        cell?.more.isHidden = !(ChatroomContext.shared?.owner ?? false)
        cell?.moreClosure = { [weak self] user in
            self?.operationUser(user: user)
        }
        cell?.selectionStyle = .none
        return cell ?? ChatroomParticipantsCell()
    }
    
    open override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if UInt(self.users.count)%Appearance.membersPageSize == 0,self.users.count - 2 == indexPath.row,self.fetchFinish {
            self.fetchFinish = false
            self.fetchUsers()
        }
    }
    
    private func filterItems(user: UserInfoProtocol) {
        if let map = ChatroomContext.shared?.muteMap {
            let mute = map[user.userId] ?? false
            if mute {
                if let index = Appearance.defaultOperationUserActions.firstIndex(where: { $0.tag == "Mute"
                }) {
                    Appearance.defaultOperationUserActions[index] = ActionSheetItem(title: "barrage_long_press_menu_unmute".chatroom.localize, type: .normal, tag: "unmute")
                }
            } else {
                if let index = Appearance.defaultOperationUserActions.firstIndex(where: { $0.tag == "unmute"
                }) {
                    Appearance.defaultOperationUserActions[index] = ActionSheetItem(title: "barrage_long_press_menu_mute".chatroom.localize, type: .normal, tag: "Mute")
                }
            }
        }
    }
    
    private func operationUser(user: UserInfoProtocol) {
        self.filterItems(user: user)
        DialogManager.shared.showUserActions(actions: Appearance.defaultOperationUserActions) { item in
            switch item.tag {
            case "Mute":
                self.roomService.mute(userId: user.userId, completion: { [weak self] error in
                    guard let `self` = self else { return }
                    if error == nil {
                        self.users.removeAll { $0.userId == user.userId }
                        self.tableView.reloadDataSafe()
                    } else {
                        self.makeToast(toast: error == nil ? "Remove successful!":"\(error?.errorDescription ?? "")",style: Theme.style == .light ? .light:.dark,duration: 2)
                    }
                })
            case "unmute":
                self.roomService.unmute(userId: user.userId, completion: { [weak self] error in
                    guard let `self` = self else { return }
                    if error == nil {
                        self.users.removeAll { $0.userId == user.userId }
                        self.tableView.reloadDataSafe()
                    } else {
                        self.makeToast(toast: error == nil ? "Remove successful!":"\(error?.errorDescription ?? "")",style: Theme.style == .light ? .light:.dark,duration: 2)
                    }
                })
            case "Remove":
                DialogManager.shared.showAlert(content: "Remove `\(user.nickName.isEmpty ? user.userId:user.nickName)`.Are you sure?", showCancel: true, showConfirm: true) { [weak self] in
                    guard let `self` = self else { return }
                    self.roomService.kick(userId: user.userId) { [weak self] error in
                        guard let `self` = self else { return }
                        self.search?.removeUser(userId: user.userId)
                        self.makeToast(toast: error == nil ? "Remove successful!":"\(error?.errorDescription ?? "")",style: Theme.style == .light ? .light:.dark,duration: 2)
                    }
                }
            default:
                item.action?(item)
            }
        }
    }
}

extension ParticipantsController: SearchBarActionEvents {
    
    public func onSearchBarClicked() {
        self.search = SearchViewController(rawSources: self.rawSources()) { [weak self] user in
            self?.operationUser(user: user)
        } didSelect: { user in
            
        }
        self.present(self.search!, animated: true)
    }
    
    private func rawSources() -> [UserInfoProtocol] {
        var sources = [UserInfoProtocol]()
        for user in self.users {
            sources.append(user)
        }
        return sources
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


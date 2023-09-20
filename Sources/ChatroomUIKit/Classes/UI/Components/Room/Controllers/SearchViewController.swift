//
//  SearchTableViewController.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/15.
//

import UIKit

@objc public class SearchViewController: UITableViewController,UISearchResultsUpdating {
        
    public private(set) lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.searchBar.placeholder = "Search".chatroom.localize
        search.obscuresBackgroundDuringPresentation = true
        return search
    }()
    
    public private(set) var rawSources = [UserInfoProtocol]() {
        didSet {
            if !self.searchController.isActive {
                if self.rawSources.count <= 0  {
                    self.tableView.backgroundView = self.empty
                } else {
                    self.tableView.backgroundView = nil
                }
            }
        }
    }
    
    public private(set) var searchResults = [UserInfoProtocol]() {
        didSet {
            if self.searchController.isActive {
                if self.searchResults.count <= 0 {
                    self.tableView.backgroundView = self.empty
                } else {
                    self.tableView.backgroundView = nil
                }
            }
        }
    }
    
    public private(set) var action: ((UserInfoProtocol) -> Void)?
    
    public private(set) lazy var empty: EmptyStateView = {
        EmptyStateView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: self.tableView.frame.height),emptyImage: UIImage(named: "empty",in: .chatroomBundle, with: nil))
    }()
    
    @objc public convenience init(rawSources: [UserInfoProtocol],cellExtensionAction: @escaping ((UserInfoProtocol) -> Void),didSelect: @escaping ((UserInfoProtocol) -> Void)) {
        self.init()
        self.action = cellExtensionAction
        self.rawSources = rawSources
        self.searchResults = rawSources
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
                
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.tableView.rowHeight = Appearance.membersRowHeight
        self.tableView.register(ChatroomParticipantsCell.self, forCellReuseIdentifier: "SearchResultCell")
        self.definesPresentationContext = true
        _ = self.searchController.publisher(for: \.isActive).sink { [weak self] status in
            if !status {
                self?.searchResults.removeAll()
            }
        }
    }
        
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchController.isActive {
            return self.searchResults.count
        }
        return self.rawSources.count
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as? ChatroomParticipantsCell
        if cell == nil {
            cell = ChatroomParticipantsCell(style: .default, reuseIdentifier: "SearchResultCell")
        }
        if self.searchController.isActive {
            if let item = self.searchResults[safe: indexPath.row] {
                cell?.refresh(user: item)
            }
        } else {
            if let item = self.rawSources[safe: indexPath.row] {
                cell?.refresh(user: item)
            }
        }
        cell?.moreClosure = { [weak self] in
            self?.action?($0)
        }
        cell?.selectionStyle = .none
        return cell ?? ChatroomParticipantsCell()
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.searchController.isActive {
            if let item = self.searchResults[safe: indexPath.row] {
                self.action?(item)
            }
        } else {
            if let item = self.rawSources[safe: indexPath.row] {
                self.action?(item)
            }
        }
        
    }
    
    public func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text,!searchText.isEmpty {
            for user in self.rawSources {
                if (user.nickName as NSString).range(of: searchText).location != NSNotFound, (user.nickName as NSString).range(of: searchText).length >= 0 {
                    if !self.searchResults.contains(where: { $0.nickName == user.nickName
                    }) {
                        self.searchResults.append(user)
                    }
                }
            }
            if self.searchResults.count <= 0 {
                self.tableView.backgroundView = self.empty
            }
            self.tableView.reloadData()
        }
    }
}



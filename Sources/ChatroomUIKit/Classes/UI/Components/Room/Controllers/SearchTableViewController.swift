//
//  SearchTableViewController.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/15.
//

import UIKit

public protocol SearchDisplayProtocol {
    var searchKeyword: String {set get}
}

public protocol SearchDriver {
    
    var action: ((SearchDisplayProtocol) -> Void)? {set get}
    
    func refresh(item: SearchDisplayProtocol)
}

public class SearchViewController<SearchResultCell:UITableViewCell&SearchDriver>: UITableViewController,UISearchResultsUpdating {
        
    public private(set) lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.searchBar.placeholder = "Search".chatroom.localize
        search.obscuresBackgroundDuringPresentation = true
        return search
    }()
    
    public private(set) var rawSources = [SearchDisplayProtocol]()
    
    public private(set) var searchResults = [SearchDisplayProtocol]()
    
    public private(set) var action: ((SearchDisplayProtocol) -> Void)?
    
    convenience init(rawSources: [SearchDisplayProtocol] = [SearchDisplayProtocol](),cellExtenAction: @escaping ((SearchDisplayProtocol) -> Void),didSelect: @escaping ((SearchDisplayProtocol) -> Void)) {
        self.init()
        self.action = cellExtenAction
        self.rawSources = rawSources
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
                
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.tableView.register(SearchResultCell.self, forCellReuseIdentifier: "SearchResultCell")
        self.definesPresentationContext = true
        _ = self.searchController.publisher(for: \.isActive).sink { [weak self] status in
            if !status {
                self?.searchResults.removeAll()
            }
        }
    }
        
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchController.isActive && !self.searchResults.isEmpty {
            return self.searchResults.count
        }
        return self.rawSources.count
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as? SearchResultCell
        if cell == nil {
            cell = SearchResultCell(style: .default, reuseIdentifier: "SearchResultCell")
        }
        if self.searchController.isActive && !self.searchResults.isEmpty {
            if let item = self.searchResults[safe: indexPath.row] {
                cell?.refresh(item: item)
            }
        } else {
            if let item = self.rawSources[safe: indexPath.row] {
                cell?.refresh(item: item)
            }
        }
        cell?.action = { [weak self] in
            self?.action?($0)
        }
        cell?.selectionStyle = .none
        return cell ?? SearchResultCell()
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.searchController.isActive && !self.searchResults.isEmpty {
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
        if let searchText = searchController.searchBar.text {
            self.searchResults = self.rawSources.filter({ $0.searchKeyword == searchText })
            self.tableView.reloadData()
        }
    }
}



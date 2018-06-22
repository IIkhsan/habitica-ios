//
//  GuildOverviewViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import ReactiveSwift
import Habitica_Models

class GuildOverviewViewController: HRPGBaseViewController, UISearchBarDelegate {
    
    let segmentedWrapper = UIView()
    let headerImageView = UIImageView()
    let headerSeparator = UIView()
    let segmentedFilterControl = UISegmentedControl(items: [L10n.myGuilds, L10n.discover])
    
    var dataSource: GuildsOverviewDataSource?
    
    var isShowingPrivateGuilds: Bool {
        return segmentedFilterControl.selectedSegmentIndex == 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.segmentedFilterControl.selectedSegmentIndex = 0
        self.segmentedFilterControl.addTarget(self, action: #selector(switchFilter), for: .valueChanged)
        segmentedWrapper.addSubview(self.segmentedFilterControl)
        headerImageView.image = HabiticaIcons.imageOfGuildHeaderCrest
        headerImageView.contentMode = .center
        segmentedWrapper.addSubview(self.headerImageView)
        headerSeparator.backgroundColor = UIColor.gray700()
        segmentedWrapper.addSubview(headerSeparator)
        layoutHeader()
        topHeaderCoordinator?.alternativeHeader = segmentedWrapper
        topHeaderCoordinator.hideHeader = false
        topHeaderCoordinator.followScrollView = false
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.keyboardDismissMode = .onDrag
        
        dataSource = GuildsOverviewDataSource()
        dataSource?.tableView = self.tableView
        
        let searchbar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        searchbar.placeholder = L10n.search
        searchbar.delegate = self
        self.tableView.tableHeaderView = searchbar
    }
    
    override func viewWillLayoutSubviews() {
        layoutHeader()
        super.viewWillLayoutSubviews()
    }
    
    private func layoutHeader() {
        let viewWidth = view.frame.size.width
        headerImageView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: 58)
        headerSeparator.frame = CGRect(x: 0, y: 70, width: viewWidth, height: 2)
        let size = segmentedFilterControl.intrinsicContentSize
        segmentedFilterControl.frame = CGRect(x: 8, y: 84, width: viewWidth-16, height: size.height)
        segmentedWrapper.frame = CGRect(x: 0, y: 0, width: viewWidth, height: 88+size.height)
    }
    
    @objc
    private func refresh() {
        dataSource?.retrieveData(completed: {[weak self] in
            self?.refreshControl?.endRefreshing()
        })
    }
    
    @objc
    private func switchFilter() {
        dataSource?.isShowingPrivateGuilds = isShowingPrivateGuilds
        
        if isShowingPrivateGuilds {
            tableView.separatorStyle = .none
        } else {
            tableView.separatorStyle = .singleLine
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.dataSource?.searchText = searchText
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Social.showGuildSegue.rawValue, let cell = sender as? UITableViewCell {
            let destViewController = segue.destination as? SplitSocialViewController
            let indexPath = tableView.indexPath(for: cell)
            destViewController?.groupID = dataSource?.item(at: indexPath)?.id
        }
    }
}

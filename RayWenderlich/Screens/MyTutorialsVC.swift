//
//  MyTutorialsViewController.swift
//  RayWenderlich
//
//  Created by Giuliano Soria Pazos on 2020-08-01.
//

import UIKit

protocol MyTutorialsVCDelegate: class {
//    var filteredItems: [SavedItem] { get set }
    func updateData(with filter: [SavedItem])
}

class MyTutorialsVC: UIViewController {
    
    weak var delegate: MyTutorialsVCDelegate!
    
    var segmentedControl: UISegmentedControl!
    var inProgressView = UIView()
    var completedView = UIView()
    var bookmarksView = UIView()
    
    static var bookmarkedItems: [SavedItem] = []
    static var completedItems: [SavedItem] = []
    static var inProgressItems: [SavedItem] = []
    var filteredItems : [SavedItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewController()
        configureSegmentedControl()
        layoutUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureBookmarksVC()
        configureInProgressVC()
        configureCompletedVC()
    }
    
    func configureViewController() {
        view.backgroundColor = .secondarySystemBackground
        navigationController?.navigationBar.tintColor = .secondaryLabel
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let settingsButton = UIBarButtonItem(image: Images.settings, style: .done, target: self, action: #selector(settingsButtonTapped))
        navigationItem.rightBarButtonItem = settingsButton
    }
    
    @objc func settingsButtonTapped() {
        
    }
    
    func layoutUI() {
        view.addSubviews(
            inProgressView,
            completedView,
            bookmarksView
        )
        inProgressView.translatesAutoresizingMaskIntoConstraints = false
        completedView.translatesAutoresizingMaskIntoConstraints = false
        bookmarksView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bookmarksView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            bookmarksView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bookmarksView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bookmarksView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            inProgressView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            inProgressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inProgressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inProgressView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            completedView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            completedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            completedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            completedView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func configureBookmarksVC() {
        self.add(childVC: BookmarksVC(with: MyTutorialsVC.bookmarkedItems), to: self.bookmarksView)
    }
    
    func configureInProgressVC() {
        self.add(childVC: InProgressVC(), to: self.inProgressView)
    }
    
    func configureCompletedVC() {
        self.add(childVC: CompletedVC(with: MyTutorialsVC.completedItems), to: self.completedView)
    }
    
    func configureSegmentedControl() {
        segmentedControl = UISegmentedControl(items: ["In Progress", "Completed", "Bookmarks"])
        segmentedControl.selectedSegmentIndex = 2
        segmentedControl.addTarget(self, action: #selector(changeValue(_:)), for: .valueChanged)
    
        view.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        let padding: CGFloat = 20
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            segmentedControl.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    @objc func changeValue(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            inProgressView.isHidden = false
            completedView.isHidden = true
            bookmarksView.isHidden = true
        case 1:
            inProgressView.isHidden = true
            completedView.isHidden = false
            bookmarksView.isHidden = true
        default:
            inProgressView.isHidden = true
            completedView.isHidden = true
            bookmarksView.isHidden = false
        }
    }
}

extension MyTutorialsVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            filteredItems.removeAll()
            delegate.updateData(with: BookmarksVC.items)
            return
        }
        
        filteredItems = BookmarksVC.items.filter { $0.attributes.name.lowercased().contains(filter.lowercased()) }
        delegate.updateData(with: filteredItems)
    }
}

extension MyTutorialsVC: UISearchBarDelegate {
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        let destVC = FiltersVC()
        destVC.title = "Filters"
        
        let navController = UINavigationController(rootViewController: destVC)
        present(navController, animated: true)
    }
}

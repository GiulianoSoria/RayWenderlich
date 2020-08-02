//
//  MyTutorialsViewController.swift
//  RayWenderlich
//
//  Created by Giuliano Soria Pazos on 2020-08-01.
//

import UIKit

class MyTutorialsVC: UIViewController {
    
    var segmentedControl: UISegmentedControl!
    var inProgressView = UIView()
    var completedView = UIView()
    var bookmarksView = UIView()
    
    static var bookmarkedItems: [SavedItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewController()
        configureBookmarksVC()
        configureSegmentedControl()
        layoutUI()
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
            bookmarksView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func configureBookmarksVC() {
        self.add(childVC: BookmarksVC(with: MyTutorialsVC.bookmarkedItems), to: self.bookmarksView)
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

//
//  ItemDetailViewController.swift
//  RayWenderlich
//
//  Created by Giuliano Soria Pazos on 2020-08-01.
//

import UIKit

class ItemDetailVC: UIViewController {
    
    var item: Item!
    
    var playerView = UIView()
    var courseInfoView = UIView()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(with item: Item) {
        self.init(nibName: nil, bundle: nil)
        self.item = item
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewController()
        configureCourseInfoVC(with: item)
        configurePlayerVC()
        layoutUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getDownload()
        getBookmark()
    }
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = UIColor(hue:0.365, saturation:0.527, brightness:0.506, alpha:1)
    }
    
    func layoutUI() {
        view.addSubviews(playerView, courseInfoView)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        courseInfoView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerView.heightAnchor.constraint(equalToConstant: 300),
            
            courseInfoView.topAnchor.constraint(equalTo: playerView.bottomAnchor),
            courseInfoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            courseInfoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            courseInfoView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func configurePlayerVC() {
        self.add(childVC: PlayerVC(with: item), to: self.playerView)
    }
    
    func configureCourseInfoVC(with item: Item) {
        self.add(childVC: CourseInfoVC(with: item), to: self.courseInfoView)
    }
    
    func getDownload() {
        PersistenceManager.retreiveItems(for: Keys.downloads) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let downloads):
                for download in downloads {
                    if download.id == self.item.id {
                        self.item.isDownloaded = true
                        self.configureCourseInfoVC(with: download)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async { UIHelper.createAlertController(title: "Error", message: error.rawValue, in: self) }
            }
        }
    }
    
    func getBookmark() {
        PersistenceManager.retreiveItems(for: Keys.bookmarks) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let bookmarks):
                for bookmark in bookmarks {
                    if bookmark.id == self.item.id {
                        self.item.isBookmarked = true
                        self.configureCourseInfoVC(with: bookmark)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async { UIHelper.createAlertController(title: "Error!", message: error.rawValue, in: self) }
            }
        }
    }
}


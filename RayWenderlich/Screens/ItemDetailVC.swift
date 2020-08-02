//
//  ItemDetailViewController.swift
//  RayWenderlich
//
//  Created by Giuliano Soria Pazos on 2020-08-01.
//

import UIKit

class ItemDetailVC: UIViewController {
    
    var item: SavedItem!
    
    var playerView = UIView()
    var courseInfoView = UIView()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(with item: SavedItem) {
        self.init(nibName: nil, bundle: nil)
        self.item = item
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewController()
        configurePlayerVC()
        configureCourseInfoVC()
        layoutUI()
    }
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
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
            playerView.heightAnchor.constraint(equalToConstant: 250),
            
            courseInfoView.topAnchor.constraint(equalTo: playerView.bottomAnchor),
            courseInfoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            courseInfoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            courseInfoView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    func configurePlayerVC() {
        self.add(childVC: PlayerVC(with: item), to: self.playerView)
    }
    
    func configureCourseInfoVC() {
        self.add(childVC: CourseInfoVC(with: item), to: self.courseInfoView)
    }
}

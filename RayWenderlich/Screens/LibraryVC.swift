//
//  ViewController.swift
//  RayWenderlich
//
//  Created by Giuliano Soria Pazos on 2020-08-01.
//

import UIKit

class LibraryVC: UIViewController {
    
    enum Section { case main }
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    var refreshControl: UIRefreshControl!
    
    var contentLabel = RWLabel(textAlignment: .left, fontSize: 20, weight: .regular, textColor: .secondaryLabel)
    var sortButton = RWButton(title: "Newest", backgroundImage: nil, backgroundColor: .clear, tintColor: .secondaryLabel)
    
    var items: [Item] = []
    var filteredItems: [Item] = []
    var sortedItems: [Item] = []
    
    var isFiltered: Bool = false
    var isSearching: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureRefreshControl()
        configureContentLabel()
        configureSortButton()
        configureCollectionView()
        configureDataSource()
        configureSearchController()
        
        fetchArticles()
        fetchVideos()
    }

    func configureViewController() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = UIColor(hue:0.365, saturation:0.527, brightness:0.506, alpha:1)
    }

    func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(hue:0.365, saturation:0.527, brightness:0.506, alpha:1)
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
    }
    
    
    @objc func refresh(_ sender: AnyObject) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.refreshControl.endRefreshing()
        }
    }
    
    func configureSortButton() {
        sortButton.setImage(Images.sort, for: .normal)
        sortButton.setTitleColor(.secondaryLabel, for: .normal)
        view.addSubview(sortButton)
        
        sortButton.addTarget(self, action: #selector(sortButtonTapped(_:)), for: .touchUpInside)
        
        
        let padding: CGFloat = 10
        
        NSLayoutConstraint.activate([
            sortButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            sortButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            sortButton.heightAnchor.constraint(equalToConstant: 44),
            sortButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func configureContentLabel() {
        contentLabel.text = "All"
        view.addSubview(contentLabel)
        
        let padding: CGFloat = 10
        
        NSLayoutConstraint.activate([
            contentLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            contentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            contentLabel.widthAnchor.constraint(equalToConstant: 150),
            contentLabel.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UIHelper.createCollectionViewFlowLayout(in: view))
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: sortButton.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        collectionView.addSubview(refreshControl)
        collectionView.backgroundColor = .secondarySystemBackground
        
        collectionView.register(ItemCell.self, forCellWithReuseIdentifier: ItemCell.reuseID)
        collectionView.delegate = self
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, item -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCell.reuseID, for: indexPath) as! ItemCell
            cell.setLibraryCell(with: item)
            
            return cell
        })
    }
    
    func updateUI(with items: [Item]) {
        self.items.append(contentsOf: items)
        updateData(with: self.items)
    }
 
    func updateData(with items: [Item]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        DispatchQueue.main.async { self.dataSource.apply(snapshot, animatingDifferences: true) }
    }
    
    func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchBar.showsBookmarkButton = true
        searchController.searchBar.setImage(Images.filter, for: .bookmark, state: .normal)
        
        searchController.searchBar.placeholder = "Search..."
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
    }
    
    @objc func sortButtonTapped(_ sender: UIButton) {
        if sender.titleLabel?.text == "Newest" {
            sortByPopularity()
        } else {
            sortByDate()
        }
    }

    @objc func sortByPopularity() {
        let activeItems = isFiltered ? filteredItems : items
        sortedItems = activeItems.sorted { $0.attributes.popularity > $1.attributes.popularity }
        
        updateData(with: sortedItems)
        sortButton.setTitle("Popular", for: .normal)
    }
    
    
    @objc func sortByDate() {
        let activeItems = isFiltered ? filteredItems : items
        sortedItems = activeItems.sorted { $0.attributes.releasedAt.convertToDate()!.convertToInt() > $1.attributes.releasedAt.convertToDate()!.convertToInt() }
        
        updateData(with: sortedItems)
        sortButton.setTitle("Newest", for: .normal)
    }
    
    func fetchArticles() {
        NetworkManager.shared.getArticles { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let articles):
                self.updateUI(with: articles.data)
            case .failure(let error):
                DispatchQueue.main.async { UIHelper.createAlertController(title: "Error", message: error.rawValue, in: self) }
            }
        }
    }
    
    func fetchVideos() {
        NetworkManager.shared.getVideos { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let videos):
                self.updateUI(with: videos.data)
            case .failure(let error):
                DispatchQueue.main.async { UIHelper.createAlertController(title: "Error", message: error.rawValue, in: self) }
            }
        }
    }
}

extension LibraryVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let activeItems = isSearching ? filteredItems : items
        let item = activeItems[indexPath.item]
        
        let savedItem = SavedItem(id: item.id, type: item.type, attributes: item.attributes, isDownloaded: false, isBookmarked: false)
        
        let destVC = ItemDetailVC(with: savedItem)
        
        navigationController?.pushViewController(destVC, animated: true)
    }
}

extension LibraryVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width - 20
        let height: CGFloat = 170
        
        return CGSize(width: width, height: height)
    }
}

extension LibraryVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            filteredItems.removeAll()
            updateData(with: items)
            isSearching = false
            return
        }
        
        isSearching = true
        filteredItems = items.filter { $0.attributes.name.lowercased().contains(filter.lowercased()) }
        updateData(with: filteredItems)
    }
}

extension LibraryVC: UISearchBarDelegate {
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        let destVC = FiltersVC()
        destVC.title = "Filters"
        destVC.delegate = self
        
        let navController = UINavigationController(rootViewController: destVC)
        present(navController, animated: true)
    }
}

extension LibraryVC: FiltersVCDelegate {
    func updateUI(with filter: String) {
        
        if filter == "All" {
            items.removeAll()
            fetchArticles()
            fetchVideos()
            contentLabel.text = "All"
            isFiltered = false
            return
        }
            
        for item in items {
            if item.attributes.contentType == filter.lowercased() {
                filteredItems.append(item)
                contentLabel.text = filter
                isFiltered = true
            }
        }
        
        updateData(with: filteredItems)
    }
}

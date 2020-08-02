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
    
    var items: [Item] = []
    var filteredItems: [Item] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureRefreshControl()
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
    
    @objc func filterButtonTapped() {
        print("Filter button tapped!")
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
    
    func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UIHelper.createCollectionViewFlowLayout(in: view))
        view.addSubview(collectionView)
        collectionView.pinToEdges(of: view)
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
        navigationItem.searchController = searchController
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
    }
    
    func updateUI(with items: [Item]) {
        updateData(with: self.items)
    }
    
    func fetchArticles() {
        NetworkManager.shared.getArticles { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let articles):
                self.items.append(contentsOf: articles.data)
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
                self.items.append(contentsOf: videos.data)
                self.updateUI(with: videos.data)
            case .failure(let error):
                DispatchQueue.main.async { UIHelper.createAlertController(title: "Error", message: error.rawValue, in: self) }
            }
        }
    }
}

extension LibraryVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
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
            return
        }
        
        filteredItems = items.filter { $0.attributes.name.lowercased().contains(filter.lowercased()) }
        updateData(with: filteredItems)
    }
}

extension LibraryVC: UISearchBarDelegate {
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        let destVC = FiltersVC()
        destVC.title = "Filters"
        
        let navController = UINavigationController(rootViewController: destVC)
        present(navController, animated: true)
    }
}

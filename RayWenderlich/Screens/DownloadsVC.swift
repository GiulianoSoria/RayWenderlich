//
//  DownloadsViewController.swift
//  RayWenderlich
//
//  Created by Giuliano Soria Pazos on 2020-08-01.
//

import UIKit

class DownloadsVC: UIViewController {
    
    enum Section { case main }
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, SavedItem>!
    
    static var items: [SavedItem] = []
    var filteredItems: [SavedItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewController()
        configureCollectionView()
        configureDataSource()
        configureSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getDownloads()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateDownloads(with: DownloadsVC.items)
    }
    
    func configureViewController() {
        view.backgroundColor = .secondarySystemBackground
        navigationController?.navigationBar.tintColor = .systemGreen
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UIHelper.createCollectionViewFlowLayout(in: view))
        view.addSubview(collectionView)
        collectionView.pinToEdges(of: view)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .secondarySystemBackground
        
        collectionView.register(ItemCell.self, forCellWithReuseIdentifier: ItemCell.reuseID)
        collectionView.delegate = self
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, SavedItem>(collectionView: collectionView, cellProvider: { collectionView, indexPath, item -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCell.reuseID, for: indexPath) as! ItemCell
            cell.setPersistedCell(with: item)
            
            return cell
        })
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
    
    func updateData(with items: [SavedItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SavedItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        DispatchQueue.main.async { self.dataSource.apply(snapshot, animatingDifferences: true) }
    }
    
    func getDownloads() {
        PersistenceManager.retreiveItems(for: Keys.downloads) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let downloads):
                DownloadsVC.items = downloads
                self.updateData(with: downloads)
            case .failure(let error):
                DispatchQueue.main.async { UIHelper.createAlertController(title: "Error", message: error.rawValue, in: self) }
            }
        }
    }
    
    func updateDownloads(with items: [SavedItem]) {
        for item in items {
            PersistenceManager.updateItems(for: Keys.downloads, with: item, actionType: .add) { error in
                guard let _ = error else {
                    print("Successfully updated persisted downloads!")
                    return
                }
            }
        }
    }
}

extension DownloadsVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let destVC = ItemDetailVC(with: DownloadsVC.items[indexPath.row])
        
        navigationController?.pushViewController(destVC, animated: true)
    }
}

extension DownloadsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width - 20
        let height: CGFloat = 170
        
        return CGSize(width: width, height: height)
    }
}

extension DownloadsVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            filteredItems.removeAll()
            updateData(with: DownloadsVC.items)
            return
        }
        
        filteredItems = DownloadsVC.items.filter { $0.attributes.name.lowercased().contains(filter.lowercased()) }
        updateData(with: filteredItems)
    }
}

extension DownloadsVC: UISearchBarDelegate {
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        let destVC = FiltersVC()
        destVC.title = "Filters"
        
        let navController = UINavigationController(rootViewController: destVC)
        present(navController, animated: true)
    }
}

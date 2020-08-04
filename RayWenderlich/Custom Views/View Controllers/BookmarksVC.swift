//
//  BookmarksVC.swift
//  RayWenderlich
//
//  Created by Giuliano Soria Pazos on 2020-08-02.
//

import UIKit

class BookmarksVC: UIViewController {

    enum Section { case main }
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, SavedItem>!
    
    static var items: [SavedItem] = []
    var filteredItems: [SavedItem] = []
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(with items: [SavedItem]) {
        self.init(nibName: nil, bundle: nil)
        BookmarksVC.items = MyTutorialsVC.bookmarkedItems
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewController()
        configureCollectionView()
        configureDataSource()
        getBookmarks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getBookmarks()
    }
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        
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
    
    func getBookmarks() {
        PersistenceManager.retreiveItems(for: Keys.bookmarks) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let bookmarks):
                BookmarksVC.items = bookmarks
                self.updateData(with: bookmarks)
            case .failure(let error):
                DispatchQueue.main.async { UIHelper.createAlertController(title: "Error", message: error.rawValue, in: self) }
            }
        }
    }
    
    func updateBookmarks(with items: [SavedItem]) {
        for item in items {
            PersistenceManager.updateItems(for: Keys.downloads, with: item, actionType: .add) { error in
                guard let _ = error else {
                    print("Successfully updated persisted bookmarks!")
                    return
                }
            }
        }
    }
    
}

extension BookmarksVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let destVC = ItemDetailVC(with: BookmarksVC.items[indexPath.row])
        
        navigationController?.pushViewController(destVC, animated: true)
    }
}

extension BookmarksVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width - 20
        let height: CGFloat = 170
        
        return CGSize(width: width, height: height)
    }
}

extension BookmarksVC: MyTutorialsVCDelegate {
    
    func updateData(with items: [SavedItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SavedItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        DispatchQueue.main.async { self.dataSource.apply(snapshot, animatingDifferences: true) }
        updateBookmarks(with: items)
    }
}

//extension BookmarksVC: UISearchBarDelegate {
//
//}
//
//extension BookmarksVC: UISearchResultsUpdating {
//    func updateSearchResults(for searchController: UISearchController) {
//        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
//            filteredItems.removeAll()
//            updateData(with: BookmarksVC.items)
//            return
//        }
//
//        filteredItems = BookmarksVC.items.filter { $0.attributes.name.lowercased().contains(filter.lowercased()) }
//        updateData(with: filteredItems)
//    }
//
//
//}

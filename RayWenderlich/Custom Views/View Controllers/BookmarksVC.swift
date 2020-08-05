//
//  BookmarksVC.swift
//  RayWenderlich
//
//  Created by Giuliano Soria Pazos on 2020-08-02.
//

import UIKit

protocol BookmarksVCDelegate: class {
    func updateData(on item: Item)
}

class BookmarksVC: UIViewController {

    enum Section { case main }
    
    weak var delegate: BookmarksVCDelegate!
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    static var items: [Item] = []
    var filteredItems: [Item] = []
    
    var isAdding: Bool = false
    var isRemoving: Bool = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(with items: [Item]) {
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
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, item -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCell.reuseID, for: indexPath) as! ItemCell
            cell.setPersistedCell(with: item)
            
            return cell
        })
    }
    
    func updateUI(with bookmark: Item) {
        if isRemoving {
            BookmarksVC.items.removeAll { $0.id == bookmark.id }
        } else if isAdding {
            BookmarksVC.items.append(bookmark)
        }
        updateData(on: BookmarksVC.items)
    }
    
    func updateData(on bookmarks: [Item]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(bookmarks)
        DispatchQueue.main.async { self.dataSource.apply(snapshot, animatingDifferences: true) }
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
    
    func updateBookmarks(with items: [Item]) {
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
    
    func updateData(with items: [Item]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
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

extension BookmarksVC: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return nil
    }
        
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { actions -> UIMenu? in
            let bookmark = BookmarksVC.items[indexPath.row]
            
            let completed = UIAction(title: "Mark as Completed", image: Images.completed) { [weak self] action in
                guard let self = self else { return }
                
                PersistenceManager.updateItems(for: Keys.completed, with: bookmark, actionType: .add) { [weak self] error in
                    guard let self = self else { return }
                    
                    self.isAdding = true
                    
                    guard let error = error else {
                        DispatchQueue.main.async { UIHelper.createAlertController(title: "Added!", message: "Successfully added from completed!", in: self) }
                        self.isAdding = false
                        return
                    }
                    
                    DispatchQueue.main.async { UIHelper.createAlertController(title: "Error", message: error.rawValue, in: self) }
                }
            }
            
            let share = UIAction(title: "Share Link", image: Images.share) { [weak self] action in
                guard let self = self else { return }
                
                let activityViewController = UIActivityViewController(activityItems: [bookmark.attributes.uri], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.collectionView.cellForItem(at: indexPath)
                activityViewController.isModalInPresentation = true
                self.present(activityViewController, animated: true)
            }

            
            let remove = UIAction(title: "Remove from Bookmarks", image: Images.removeBookmark, attributes: .destructive) { action in
                let updatedBookmark = Item(id: bookmark.id, type: bookmark.type, attributes: bookmark.attributes, isDownloaded: bookmark.isDownloaded!, isBookmarked: false)
                PersistenceManager.updateItems(for: Keys.bookmarks, with: updatedBookmark, actionType: .remove) { [weak self] error in
                    guard let self = self else { return }
                    
                    self.isRemoving = true
                    
                    guard let error = error else {
                        DispatchQueue.main.async { UIHelper.createAlertController(title: "Removed!", message: "Successfully removed from bookmarks!", in: self) }
                        self.updateUI(with: bookmark)
                        self.isRemoving = false
                        return
                    }
                    
                    DispatchQueue.main.async { UIHelper.createAlertController(title: "Error", message: error.rawValue, in: self) }
                }
            }
            
            let destructive = UIMenu(title: "Remove", image: nil, options: .displayInline, children: [remove])
            
            return UIMenu(title: "Menu", children: [completed, share, destructive])
        }
            
        return configuration
    }
}

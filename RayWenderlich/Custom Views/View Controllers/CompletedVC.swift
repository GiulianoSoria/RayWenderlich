//
//  CompletedVC.swift
//  RayWenderlich
//
//  Created by Giuliano Soria Pazos on 2020-08-03.
//

import UIKit

class CompletedVC: UIViewController {
    
    enum Section { case main }
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, SavedItem>!
    
    static var items: [SavedItem] = []
    var filteredItems: [SavedItem] = []
    
    var isAdding: Bool = false
    var isRemoving: Bool = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(with items: [SavedItem]) {
        self.init(nibName: nil, bundle: nil)
        CompletedVC.items = MyTutorialsVC.completedItems
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewController()
        configureCollectionView()
        configureDataSource()
        getCompleted()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getCompleted()
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
    
    func updateUI(with completed: SavedItem) {
        if isRemoving {
            CompletedVC.items.removeAll { $0.id == completed.id }
        } else if isAdding {
            CompletedVC.items.append(completed)
        }
        updateData(on: CompletedVC.items)
    }
    
    func updateData(on completed: [SavedItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SavedItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(completed)
        DispatchQueue.main.async { self.dataSource.apply(snapshot, animatingDifferences: true) }
    }
    
    func getCompleted() {
        PersistenceManager.retreiveItems(for: Keys.completed) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let completed):
                CompletedVC.items = completed
                self.updateData(with: completed)
            case .failure(let error):
                DispatchQueue.main.async { UIHelper.createAlertController(title: "Error", message: error.rawValue, in: self) }
            }
        }
    }
    
    func updateCompleted(with items: [SavedItem]) {
        for item in items {
            PersistenceManager.updateItems(for: Keys.completed, with: item, actionType: .add) { error in
                guard let _ = error else {
                    print("Successfully updated persisted completed courses!")
                    return
                }
            }
        }
    }
    
}

extension CompletedVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let destVC = ItemDetailVC(with: CompletedVC.items[indexPath.row])
        
        navigationController?.pushViewController(destVC, animated: true)
    }
}

extension CompletedVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width - 20
        let height: CGFloat = 170
        
        return CGSize(width: width, height: height)
    }
}

extension CompletedVC: MyTutorialsVCDelegate {
    
    func updateData(with items: [SavedItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SavedItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        DispatchQueue.main.async { self.dataSource.apply(snapshot, animatingDifferences: true) }
        updateCompleted(with: items)
    }
}

//extension CompletedVC: UISearchBarDelegate {
//
//}
//
//extension CompletedVC: UISearchResultsUpdating {
//    func updateSearchResults(for searchController: UISearchController) {
//        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
//            filteredItems.removeAll()
//            updateData(with: CompletedVC.items)
//            return
//        }
//
//        filteredItems = CompletedVC.items.filter { $0.attributes.name.lowercased().contains(filter.lowercased()) }
//        updateData(with: filteredItems)
//    }
//
//
//}

extension CompletedVC: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return nil
    }
        
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { actions -> UIMenu? in
            let completed = CompletedVC.items[indexPath.row]
            
            let share = UIAction(title: "Share Link", image: Images.share) { [weak self] action in
                guard let self = self else { return }
                
                let activityViewController = UIActivityViewController(activityItems: [completed.attributes.uri], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.collectionView.cellForItem(at: indexPath)
                activityViewController.isModalInPresentation = true
                self.present(activityViewController, animated: true)
            }

            
            let remove = UIAction(title: "Remove from Completed", image: Images.removeCompleted, attributes: .destructive) { action in
                PersistenceManager.updateItems(for: Keys.completed, with: completed, actionType: .remove) { [weak self] error in
                    guard let self = self else { return }
                    
                    self.isRemoving = true
                    
                    guard let error = error else {
                        DispatchQueue.main.async { UIHelper.createAlertController(title: "Removed", message: "Successfully removed from completed!", in: self) }
                        self.updateUI(with: completed)
                        self.isRemoving = false
                        return
                    }
                    
                    DispatchQueue.main.async { UIHelper.createAlertController(title: "Error", message: error.rawValue, in: self) }
                }
            }
            
            return UIMenu(title: "Menu", children: [share, remove])
        }
            
        return configuration
    }
}

extension CompletedVC: BookmarksVCDelegate {
    func updateData(on item: SavedItem) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SavedItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems([item])
        DispatchQueue.main.async { self.dataSource.apply(snapshot, animatingDifferences: true) }
    }
}

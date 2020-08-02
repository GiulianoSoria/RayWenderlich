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
        getDownloads()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateData(with: DownloadsVC.items)
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
                self.updateData(with: downloads)
            case .failure(let error):
                DispatchQueue.main.async { UIHelper.createAlertController(title: "Error", message: error.rawValue, in: self) }
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

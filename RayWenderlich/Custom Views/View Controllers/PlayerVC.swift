//
//  PlayerVC.swift
//  RayWenderlich
//
//  Created by Giuliano Soria Pazos on 2020-08-01.
//

import UIKit

class PlayerVC: UIViewController {
    
    var item: SavedItem!
    
    var playerImageView = RWImageView(frame: .zero)
    var playButton = RWButton(title: nil, backgroundImage: Images.play, backgroundColor: .white, tintColor: .black)

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

        layoutUI()
    }
    
    func layoutUI() {
        playerImageView.downloadImage(from: item.attributes.cardArtworkUrl)
        playerImageView.alpha = 0.5
        
        view.addSubview(playerImageView)
        playerImageView.pinToEdges(of: view)
        view.addSubview(playButton)
        playButton.alpha = 1
        
        NSLayoutConstraint.activate([
            playButton.centerYAnchor.constraint(equalTo: playerImageView.centerYAnchor),
            playButton.centerXAnchor.constraint(equalTo: playerImageView.centerXAnchor),
            playButton.heightAnchor.constraint(equalToConstant: 50),
            playButton.widthAnchor.constraint(equalTo: playButton.heightAnchor)
        ])
    }
    
}

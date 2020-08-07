//
//  PlayerVC.swift
//  RayWenderlich
//
//  Created by Giuliano Soria Pazos on 2020-08-01.
//

import UIKit
import AVKit

class PlayerVC: UIViewController {
    
    var item: Item!
    
    var playerImageView = RWImageView(frame: .zero)
    var playButton = RWButton(title: nil, backgroundImage: Images.play, backgroundColor: .white, tintColor: .black)
    
    init(with item: Item) {
        super.init(nibName: nil, bundle: nil)
        self.item = item
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewController()
        layoutUI()
    }
    
    func configureViewController() {
        view.backgroundColor = .secondarySystemBackground
    }
    
    func layoutUI() {
        playerImageView.downloadImage(from: item.attributes.cardArtworkUrl)
        playerImageView.alpha = 0.5
        playerImageView.layer.cornerRadius = 0
        
        
        view.addSubview(playerImageView)
        playerImageView.pinToEdges(of: view)

        view.addSubview(playButton)
        playButton.alpha = 1
        
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            playButton.centerYAnchor.constraint(equalTo: playerImageView.centerYAnchor),
            playButton.centerXAnchor.constraint(equalTo: playerImageView.centerXAnchor),
            playButton.heightAnchor.constraint(equalToConstant: 50),
            playButton.widthAnchor.constraint(equalTo: playButton.heightAnchor)
        ])
    }
    
    @objc func playButtonTapped() {
        let videoURL = URL(string: "videoUrl")
        let player = AVPlayer(url: videoURL!)
        
        let playerVC = AVPlayerViewController()
        playerVC.allowsPictureInPicturePlayback = true
        playerVC.entersFullScreenWhenPlaybackBegins = true
        playerVC.player = player
        
        present(playerVC, animated: true) {
            playerVC.player!.play()
        }
    }
    
}

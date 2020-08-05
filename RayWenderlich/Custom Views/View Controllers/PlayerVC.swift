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

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(with item: Item) {
        self.init(nibName: nil, bundle: nil)
        self.item = item
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
        
//        let gradient = CAGradientLayer()
//        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
//        gradient.endPoint = CGPoint(x: 0.5, y: 0.6)
//        let whiteColor = UIColor.white
//        gradient.colors = [whiteColor.withAlphaComponent(0.0).cgColor, whiteColor.withAlphaComponent(1.0).cgColor, whiteColor.withAlphaComponent(1.0).cgColor]
//        gradient.locations = [NSNumber(value: 0.0),NSNumber(value: 0.2),NSNumber(value: 1.0)]
//        gradient.frame = playerImageView.bounds
//        playerImageView.layer.mask = gradient
        
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
        let videoURL = URL(string: "https://i.imgur.com/V6VfD9G.mp4")
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

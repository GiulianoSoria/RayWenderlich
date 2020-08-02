//
//  UIHelper.swift
//  RayWenderlich
//
//  Created by Giuliano Soria Pazos on 2020-08-01.
//

import UIKit

struct UIHelper {
    
    static func createCollectionViewFlowLayout(in view: UIView) -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        return layout
    }
    
    static func createAlertController(title: String, message: String, in viewController: UIViewController) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        viewController.present(ac, animated: true)
    }
}

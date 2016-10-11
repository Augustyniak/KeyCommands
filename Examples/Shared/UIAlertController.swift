//
//  Alert.swift
//  KeyCommandsExamples
//
//  Created by Rafal Augustyniak on 02/09/16.
//  Copyright © 2016 Rafał Augustyniak. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    static func presentKeyPressedAlertInAlertViewController(inViewController viewController: UIViewController, message: String) {
        let alertController = UIAlertController.init(title: "Combination of keys pressed!", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
        viewController.present(alertController, animated: true, completion: nil)
    }
    
}

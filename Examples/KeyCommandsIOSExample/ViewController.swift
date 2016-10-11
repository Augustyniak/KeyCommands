//
//  ViewController.swift
//  KeyCommandsExamples
//
//  Created by Rafal Augustyniak on 02/09/16.
//  Copyright © 2016 Rafał Augustyniak. All rights reserved.
//

import UIKit
import KeyCommands

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        KeyCommands.register(input: "r", modifierFlags: .command) {
            if self.presentedViewController == nil {
                UIAlertController.presentKeyPressedAlertInAlertViewController(inViewController: self, message: "⌘+R")
            }
        }
    }
    
}


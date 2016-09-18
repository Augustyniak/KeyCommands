//
//  KeyCommands.swift
//  KeyCommands
//
//  Created by Rafal Augustyniak on 01/09/16.
//  Copyright © 2016 Rafał Augustyniak. All rights reserved.
//

import UIKit


#if (arch(i386) || arch(x86_64)) && (os(iOS) || os(tvOS))
    struct KeyActionableCommand {
        private let keyCommand: UIKeyCommand
        private let actionBlock: () -> ()
        
        func matches(input: String, modifierFlags: UIKeyModifierFlags) -> Bool {
            return keyCommand.input == input && keyCommand.modifierFlags == modifierFlags
        }
    }
    
    func == (lhs: KeyActionableCommand, rhs: KeyActionableCommand) -> Bool {
        return lhs.keyCommand.input == rhs.keyCommand.input && lhs.keyCommand.modifierFlags == rhs.keyCommand.modifierFlags
    }
    
    
    public enum KeyCommands {
        private struct Static {
            static var token: dispatch_once_t = 0
        }
        
        
        struct KeyCommandsRegister {
            static var sharedInstance = KeyCommandsRegister()
            private var actionableKeyCommands = [KeyActionableCommand]()
        }
        
        /**
         
         Registers key command for specified input and modifier flags. Unregisters previously registered key commands
         matching provided input and modifier flags. Does nothing when application runs on actual device.
         
         - parameter input:          Key for which key command should be registered.
         
         - parameter modifierFlags:  Combination of modifier flags for which key command should be registered.
         
         */
        public static func registerKeyCommand(input: String, modifierFlags: UIKeyModifierFlags, action: () -> ()) {
            dispatch_once(&Static.token) {
                ExchangeImplementations(class: UIApplication.self, originalSelector: Selector("keyCommands"), swizzledSelector: #selector(UIApplication.KYC_keyCommands));
            }
            
            let keyCommand = UIKeyCommand(input: input, modifierFlags: modifierFlags, action: #selector(UIApplication.KYC_handleKeyCommand(_:)), discoverabilityTitle: "")
            let actionableKeyCommand = KeyActionableCommand(keyCommand: keyCommand, actionBlock: action)
            
            let index = KeyCommandsRegister.sharedInstance.actionableKeyCommands.indexOf({ return $0 == actionableKeyCommand })
            if let index = index {
                KeyCommandsRegister.sharedInstance.actionableKeyCommands.removeAtIndex(index)
            }
            
            KeyCommandsRegister.sharedInstance.actionableKeyCommands.append(actionableKeyCommand)
        }
        
        /**
         
         Unregisters key command matching specified input and modifier flags. Does nothing when application runs on actual device.
         
         - parameter input:          Key of key command that should be unregistered.
         
         - parameter modifierFlags:  Combination of modifier flags of key command that should be unregistered.
         
         */
        public static func unregisterKeyCommand(input: String, modifierFlags: UIKeyModifierFlags) {
            let index = KeyCommandsRegister.sharedInstance.actionableKeyCommands.indexOf({ return $0.matches(input, modifierFlags: modifierFlags) })
            if let index = index {
                KeyCommandsRegister.sharedInstance.actionableKeyCommands.removeAtIndex(index)
            }
        }
    }
    
    
    extension UIApplication {
        dynamic func KYC_keyCommands() -> [UIKeyCommand] {
            return KeyCommands.KeyCommandsRegister.sharedInstance.actionableKeyCommands.map({ return $0.keyCommand })
        }
        
        func KYC_handleKeyCommand(keyCommand: UIKeyCommand) {
            for command in KeyCommands.KeyCommandsRegister.sharedInstance.actionableKeyCommands {
                if command.matches(keyCommand.input, modifierFlags: keyCommand.modifierFlags) {
                    command.actionBlock()
                }
            }
        }
    }
    
    
    func ExchangeImplementations(class classs: AnyClass, originalSelector: Selector, swizzledSelector: Selector ){
        let originalMethod = class_getInstanceMethod(classs, originalSelector)
        let originalMethodImplementation = method_getImplementation(originalMethod)
        let originalMethodTypeEncoding = method_getTypeEncoding(originalMethod)
        
        let swizzledMethod = class_getInstanceMethod(classs, swizzledSelector)
        let swizzledMethodImplementation = method_getImplementation(swizzledMethod)
        let swizzledMethodTypeEncoding = method_getTypeEncoding(swizzledMethod)
        
        let didAddMethod = class_addMethod(classs, originalSelector, swizzledMethodImplementation, swizzledMethodTypeEncoding)
        if didAddMethod {
            class_replaceMethod(classs, swizzledSelector, originalMethodImplementation, originalMethodTypeEncoding)
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
#else
    
    public enum KeyCommands {
        /**
         
         Registers key command for specified input and modifier flags. Unregisters previously registered key commands
         matching provided input and modifier flags. Does nothing when application runs on actual device.
         
         - parameter input:          Key for which key command should be registered.
         
         - parameter modifierFlags:  Combination of modifier flags for which key command should be registered.
         
         */
        public static func registerKeyCommand(input: String, modifierFlags: UIKeyModifierFlags, action: () -> ()) {}
        
        /**
         
         Unregisters key command matching specified input and modifier flags. Does nothing when application runs on actual device.
         
         - parameter input:          Key of key command that should be unregistered.
         
         - parameter modifierFlags:  Combination of modifier flags of key command that should be unregistered.
         
         */
        public static func unregisterKeyCommand(input: String, modifierFlags: UIKeyModifierFlags) {}
    }
    
#endif

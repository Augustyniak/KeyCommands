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
        fileprivate let keyCommand: UIKeyCommand
        fileprivate let actionBlock: () -> ()
        
        func matches(_ input: String, modifierFlags: UIKeyModifierFlags) -> Bool {
            return keyCommand.input == input && keyCommand.modifierFlags == modifierFlags
        }
    }
    
    func == (lhs: KeyActionableCommand, rhs: KeyActionableCommand) -> Bool {
        return lhs.keyCommand.input == rhs.keyCommand.input && lhs.keyCommand.modifierFlags == rhs.keyCommand.modifierFlags
    }
    
    
    public enum KeyCommands {
        private static var __once: () = {
            ExchangeImplementations(class: UIApplication.self, originalSelector: #selector(getter: UIResponder.keyCommands), swizzledSelector: #selector(UIApplication.KYC_keyCommands));
        }()
        fileprivate struct Static {
            static var token: Int = 0
        }
        
        
        struct KeyCommandsRegister {
            static var sharedInstance = KeyCommandsRegister()
            fileprivate var actionableKeyCommands = [KeyActionableCommand]()
        }
        
        /**
         
         Registers key command for specified input and modifier flags. Unregisters previously registered key commands
         matching provided input and modifier flags. Does nothing when application runs on actual device.
         
         - parameter input:          Key for which key command should be registered.
         
         - parameter modifierFlags:  Combination of modifier flags for which key command should be registered.
         
         */
        public static func register(input: String, modifierFlags: UIKeyModifierFlags, action: @escaping () -> ()) {
            _ = KeyCommands.__once
            
            let keyCommand = UIKeyCommand(input: input, modifierFlags: modifierFlags, action: #selector(UIApplication.KYC_handleKeyCommand(_:)), discoverabilityTitle: "")
            let actionableKeyCommand = KeyActionableCommand(keyCommand: keyCommand, actionBlock: action)
            
            let index = KeyCommandsRegister.sharedInstance.actionableKeyCommands.index(where: { return $0 == actionableKeyCommand })
            if let index = index {
                KeyCommandsRegister.sharedInstance.actionableKeyCommands.remove(at: index)
            }
            
            KeyCommandsRegister.sharedInstance.actionableKeyCommands.append(actionableKeyCommand)
        }
        
        /**
         
         Unregisters key command matching specified input and modifier flags. Does nothing when application runs on actual device.
         
         - parameter input:          Key of key command that should be unregistered.
         
         - parameter modifierFlags:  Combination of modifier flags of key command that should be unregistered.
         
         */
        public static func unregister(input: String, modifierFlags: UIKeyModifierFlags) {
            let index = KeyCommandsRegister.sharedInstance.actionableKeyCommands.index(where: { return $0.matches(input, modifierFlags: modifierFlags) })
            if let index = index {
                KeyCommandsRegister.sharedInstance.actionableKeyCommands.remove(at: index)
            }
        }
    }
    
    
    extension UIApplication {
        dynamic func KYC_keyCommands() -> [UIKeyCommand] {
            return KeyCommands.KeyCommandsRegister.sharedInstance.actionableKeyCommands.map({ return $0.keyCommand })
        }
        
        func KYC_handleKeyCommand(_ keyCommand: UIKeyCommand) {
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

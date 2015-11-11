//
//  GameDidBeginNotificationHandler.swift
//  Swiftris
//
//  Created by Bruno Chroniaris on 10/10/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

import Foundation

class GameDidBeginNotificationHandler: NotificationHandler {
    private init(){}
    
    func post() {
        NSNotificationCenter.defaultCenter().postNotificationName(GameDidBeginNotificationHandler.notificationName, object: nil)
    }
    
    func observe(observer: AnyObject, selector: Selector) {
        NSNotificationCenter.defaultCenter().addObserver(observer, selector: selector, name: GameDidBeginNotificationHandler.notificationName, object: nil)
    }
    
    func remove(observer observer: AnyObject) {
        NSNotificationCenter.defaultCenter().removeObserver(observer, name: GameDidBeginNotificationHandler.notificationName, object: nil)
    }
    
    class var notificationName: String {
        return "GameDidBeginNotification"
    }
    
    static private(set) var singleton: NotificationHandler = GameDidBeginNotificationHandler()
}
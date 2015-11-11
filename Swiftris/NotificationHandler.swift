//
//  NotificationHandler.swift
//  Swiftris
//
//  Created by Bruno Chroniaris on 10/10/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

import Foundation

protocol NotificationHandler {
    func observe(observer: AnyObject, selector: Selector)
    func post()
    func remove(observer observer: AnyObject)
    static var notificationName: String { get }
    static var singleton: NotificationHandler { get }
}
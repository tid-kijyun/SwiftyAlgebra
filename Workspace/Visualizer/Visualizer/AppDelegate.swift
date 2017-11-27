//
//  AppDelegate.swift
//  Visualizer
//
//  Created by Taketo Sano on 2017/09/29.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        guard let vc = NSApplication.shared.mainWindow?.contentViewController as? SceneViewController else {
            fatalError()
        }
        vc.objects = generateS3()
    }

    // TODO move to some model class
    
    func generateS3(_ N: Int = 1000) -> [Visual] {
        return (0 ..< N).map { _ in Point(position: Vec4.random(-1 ... 1).normalized, color: .blue) }
    }
    
    func generateGL2(_ N: Int = 1000) -> [Visual] {
        return (0 ..< N).map { _ in
            let v = Vec4.random(-1 ... 1)
            let c: NSColor = (v.x * v.w - v.y * v.z > 0) ? .red : .blue
            return Point(position: v, color: c)
        }
    }
    
    // --TODO
}


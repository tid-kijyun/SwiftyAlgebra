//
//  Entity.swift
//  Visualizer
//
//  Created by Taketo Sano on 2017/11/27.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Cocoa
import SceneKit

class Visual {
    let color: NSColor
    var node: SCNNode? = nil
    
    init(color: NSColor) {
        self.color = color
    }
}

class Point: Visual {
    let position: Vec4
    
    init(position: Vec4, color: NSColor) {
        self.position = position
        super.init(color: color)
    }
    
    var x: CGFloat { return position.x }
    var y: CGFloat { return position.y }
    var z: CGFloat { return position.z }
    var w: CGFloat { return position.w }
    var xyz: Vec3  { return position.xyz }
}

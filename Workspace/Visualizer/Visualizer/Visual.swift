//
//  Entity.swift
//  Visualizer
//
//  Created by Taketo Sano on 2017/11/27.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Cocoa
import SceneKit
import SwiftyAlgebra

class Visual {
    let position: Vec4
    let color: NSColor
    
    init(position: Vec4, color: NSColor) {
        self.position = position
        self.color = color
    }

    var node: SCNNode? = nil
    
    var x: CGFloat { return position.x }
    var y: CGFloat { return position.y }
    var z: CGFloat { return position.z }
    var w: CGFloat { return position.w }
    var xyz: Vec3  { return position.xyz }
}

class Point: Visual {}

class Polyhedron: Visual {
    let points: [Point]
    
    init(_ K: SimplicialComplex, position: Vec4, color: NSColor) {
        let points = K.allVertices.map { v in
            return Point(position: Vec4.random(-1 ... 1).normalized, color: color)
        }
        self.points = points
        super.init(position: position, color: color)
    }
}

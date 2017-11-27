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

class Edge: Visual {
    let points: (Point, Point)
    
    init(p0: Point, p1: Point, color: NSColor) {
        self.points = (p0, p1)
        super.init(position: [p0.position, p1.position].barycenter, color: color)
    }
    
    var vector: SCNVector4 {
        return points.0.position - points.1.position
    }
    
    var length: CGFloat {
        return vector.length
    }
    
    var eulerAngles: Vec3 {
        let v = vector
        return Vec3(0, atan(v.x / v.y), 0)
    }
}

class Polyhedron: Visual {
    let edges: [Edge]
    let points: [Point]
    
    init(_ K: SimplicialComplex, position: Vec4, color: NSColor) {
        var pointMap = [Vertex : Point]()
        let points = K.allVertices.map { v -> Point in
            let p =  Point(position: Vec4.random(-1 ... 1), color: color)
            pointMap[v] = p
            return p
        }
        
        let edges = K.cells(ofDim: 1).map { s -> Edge in
            let (v0, v1) = (s.vertices[0], s.vertices[1])
            return Edge(p0: pointMap[v0]!, p1: pointMap[v1]!, color: color)
        }
        
        self.points = points
        self.edges = edges
        
        super.init(position: position, color: color)
    }
}

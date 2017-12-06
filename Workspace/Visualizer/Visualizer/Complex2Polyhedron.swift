//
//  Complex2Polyhedron.swift
//  Visualizer
//
//  Created by Taketo Sano on 2017/12/05.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation
import SceneKit
import SwiftyAlgebra

extension Polyhedron {
    convenience init(_ K: SimplicialComplex, position: SCNVector4 = SCNVector4.zero, color: NSColor = .blue) {
        var v2p = [Vertex : Point]()
        let points = K.vertices.map { v -> Point in
            let p =  Point(name: v.description, position: Vec4(Vec3.random(-1 ... 1)), color: color)
            v2p[v] = p
            return p
        }
        
        let edges = K.cells(ofDim: 1).map { s -> Edge in
            let (v0, v1) = (s.vertices[0], s.vertices[1])
            let e = Edge(name: s.description, p0: v2p[v0]!, p1: v2p[v1]!, color: color)
            return e
        }
        
        let faces = K.cells(ofDim: 2).map { s -> Triangle in
            let (v0, v1, v2) = (s.vertices[0], s.vertices[1], s.vertices[2])
            return Triangle(name: s.description, p0: v2p[v0]!, p1: v2p[v1]!, p2: v2p[v2]!, color: color)
        }
        
        let fd = ForceDirector(points, position)
        fd.run()
        
        self.init(points: points, edges: edges, faces: faces, position: position, color: color)
    }
}


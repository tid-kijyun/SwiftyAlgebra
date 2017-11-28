//
//  ForceDirecter.swift
//  Visualizer
//
//  Created by Taketo Sano on 2017/11/28.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import SceneKit
import SwiftyAlgebra

class ForceDirector {
    let l0: CGFloat = 1.0  // natural length
    let k : CGFloat = 3.0  // spring const
    let c : CGFloat = 3.0  // Coulomb const
    let d : CGFloat = 0.8  // decay
    let dt: CGFloat = 0.05
    let minE: CGFloat = 0.001
    
    let target: Polyhedron
    let center: Vec4
    
    var vel: [Vec4]
    var i = 0 // iteration

    init(_ target: Polyhedron) {
        self.target = target
        self.center = target.position
        self.vel = Array(repeating: Vec4.zero, count: target.points.count)   // velocity of each point
    }
    
    func start(maxIterations: Int = 10000) {
        while itr() > minE && i < maxIterations {
            i += 1
        }
        centrize()
    }
    
    func itr() -> CGFloat {
        let points = target.points
        var E: CGFloat = 0     // total energy
        
        for (i, p) in points.enumerated() {
            
            var force = Vec4.zero
            
            // coulomb force
            force = force + points.reduce( Vec4.zero ) { (total, q) in
                if p == q { return total }
                let v = p.position - q.position
                let r = v.length
                let f = c / (r * r) * v.normalized
                return total + f
            }
            
            // spring force
            force = force + p.connectedEdges.reduce( Vec4.zero ) { (total, e) in
                let l = e.length
                let u = (e.points.0 == p) ? e.vector.normalized : -e.vector.normalized
                let f = (k * (l - l0)) * u
                return total + f
            }
            
            let v = d * (vel[i] + dt * force)
            p.position = p.position + dt * v
            vel[i] = v
            
            E += pow(v.length, 2)
        }
        
        return E
    }
    
    func centrize() {
        let b = target.points.map{ $0.position }.barycenter
        target.points.forEach{ p in p.position = p.position - b + center }
    }
}

extension Polyhedron {
    convenience init(_ K: SimplicialComplex, position: SCNVector4 = SCNVector4.zero, color: NSColor = .blue) {
        var v2p = [Vertex : Point]()
        let points = K.vertices.map { v -> Point in
            let p =  Point(position: Vec4(Vec3.random(-1 ... 1)), color: color)
            v2p[v] = p
            return p
        }
        
        let edges = K.cells(ofDim: 1).map { s -> Edge in
            let (v0, v1) = (s.vertices[0], s.vertices[1])
            return Edge(p0: v2p[v0]!, p1: v2p[v1]!, color: color)
        }
        
        let faces = K.cells(ofDim: 2).map { s -> Triangle in
            let (v0, v1, v2) = (s.vertices[0], s.vertices[1], s.vertices[2])
            return Triangle(p0: v2p[v0]!, p1: v2p[v1]!, p2: v2p[v2]!, color: color)
        }
        
        self.init(points: points, edges: edges, faces: faces, position: Vec4.zero, color: color)
        
        let f = ForceDirector(self)
        f.start()
    }
}


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
    static let l0: CGFloat = 1.0  // natural length
    static let k : CGFloat = 3.0  // spring const
    static let c : CGFloat = 3.0  // Coulomb const
    static let d : CGFloat = 0.8  // decay
    static let dt: CGFloat = 0.05
    static let minE: CGFloat = 0.001
    
    static func apply(points: [Point], edges: [Edge], maxIterations: Int = 10000) {
        var vel: [Vec4] = Array(repeating: Vec4.zero, count: points.count)   // velocity of each point
        var i = 1

        while itr(points, edges, &vel) > minE && i < maxIterations {
            i += 1
        }
        
        centrize(points: points)
    }
    
    internal static func itr(_ points: [Point], _ edges: [Edge], _ vel: inout [Vec4]) -> CGFloat {
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
    
    private static func centrize(points: [Point]) {
        let b = points.map{$0.position}.barycenter
        points.forEach{ p in p.position = p.position - b }
    }
}

extension Polyhedron {
    convenience init(_ K: SimplicialComplex, color: NSColor = .blue) {
        var pointMap = [Vertex : Point]()
        let points = K.vertices.map { v -> Point in
            let p =  Point(position: Vec4(Vec3.random(-1 ... 1)), color: color)
            pointMap[v] = p
            return p
        }
        
        let edges = K.cells(ofDim: 1).map { s -> Edge in
            let (v0, v1) = (s.vertices[0], s.vertices[1])
            return Edge(p0: pointMap[v0]!, p1: pointMap[v1]!, color: color)
        }
        
        let faces = K.cells(ofDim: 2).map { s -> Triangle in
            let (v0, v1, v2) = (s.vertices[0], s.vertices[1], s.vertices[2])
            return Triangle(p0: pointMap[v0]!, p1: pointMap[v1]!, p2: pointMap[v2]!, color: color)
        }
        
        ForceDirector.apply(points: points, edges: edges)
        self.init(points: points, edges: edges, faces: faces, position: Vec4.zero, color: color)
    }
}


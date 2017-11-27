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

protocol EntityObserver: class {
    func update(forEntity e: Entity)
}

class Entity: Equatable {
    init(position: Vec4, color: NSColor) {
        self.position = position
        self.color = color
    }
    
    var position: Vec4 { didSet { didUpdate() } }
    var color: NSColor { didSet { didUpdate() } }
    var observers: [Weak<AnyObject>] = []
    
    var x: CGFloat { return position.x }
    var y: CGFloat { return position.y }
    var z: CGFloat { return position.z }
    var w: CGFloat { return position.w }
    var xyz: Vec3  { return position.xyz }
    
    func addObserver(_ o: EntityObserver) {
        observers.append(Weak(o as AnyObject))
    }
    
    func removeObserver(_ o: EntityObserver) {
        if let i = observers.index(where: {$0.content.flatMap{ $0 === o } ?? false }) {
            observers.remove(at: i)
        }
    }
    
    func didUpdate() {
        observers.forEach{ ($0.content as? EntityObserver)?.update(forEntity: self) }
    }

    static func ==(lhs: Entity, rhs: Entity) -> Bool {
        return lhs === rhs
    }
}

class Point: Entity {
    fileprivate var _connectedEdges: [Weak<Edge>] = []
    
    var connectedEdges: [Edge] {
        return _connectedEdges.flatMap{ $0.content }
    }
    
    func appendEdge(_ e: Edge) {
        _connectedEdges.append(Weak(e))
    }
    
    func removeEdge(_ e: Edge) {
        if let i = _connectedEdges.index(where: {$0.content.flatMap{$0 == e} ?? false}) {
            _connectedEdges.remove(at: i)
        }
    }
}

class Edge: Entity, EntityObserver {
    let points: (Point, Point)
    
    init(p0: Point, p1: Point, color: NSColor) {
        self.points = (p0, p1)
        super.init(position: [p0.position, p1.position].barycenter, color: color)
        p0.appendEdge(self)
        p1.appendEdge(self)
        p0.addObserver(self)
        p1.addObserver(self)
    }
    
    var vector: SCNVector4 {
        return points.1.position - points.0.position
    }
    
    var length: CGFloat {
        return vector.length
    }
    
    var eulerAngles: Vec3 {
        let v = vector
        return Vec3(0, atan(v.x / v.y), 0)
    }
    
    func update(forEntity e: Entity) {
        didUpdate()
    }
    
    deinit {
        points.0.removeEdge(self)
        points.1.removeEdge(self)
        points.0.removeObserver(self)
        points.1.removeObserver(self)
    }
}

class Polyhedron: Entity {
    let edges: [Edge]
    let points: [Point]
    
    init(_ K: SimplicialComplex, position: Vec4, color: NSColor) {
        var pointMap = [Vertex : Point]()
        let points = K.allVertices.map { v -> Point in
            let p =  Point(position: Vec4(Vec3.random(-1 ... 1)), color: color)
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
        
        self.relax()
        self.centrize()
    }
    
    private func relax() {
        let l0: CGFloat = 1.0  // natural length
        let k : CGFloat = 3.0  // spring const
        let c : CGFloat = 3.0  // Coulomb const
        let d : CGFloat = 0.8  // decay
        let dt: CGFloat = 0.05
        
        var vel: [Vec4] = Array(repeating: Vec4.zero, count: points.count)   // velocity of each point
        
        func itr() -> CGFloat {
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
        
        var i = 1
        while itr() > 0.001 && i < 100 {
            i += 1
        }
    }
    
    private func centrize() {
        let b = points.map{$0.position}.barycenter
        points.forEach{ p in p.position = p.position - b }
    }
}

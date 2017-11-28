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

class Triangle: Entity, EntityObserver {
    let points: (Point, Point, Point)
    
    init(p0: Point, p1: Point, p2: Point, color: NSColor) {
        self.points = (p0, p1, p2)
        
        let pos = [p0.position, p1.position, p2.position].barycenter
        super.init(position: pos, color: color)
        
        [p0, p1, p2].forEach{ $0.addObserver(self) }
    }
    
    var normalVector: Vec3 {
        let (p0, p1, p2) = points
        let v1 = (p1.position - p0.position).xyz
        let v2 = (p2.position - p0.position).xyz
        return (v1 × v2).normalized
    }
    
    func update(forEntity e: Entity) {
        didUpdate()
    }
    
    deinit {
        points.0.removeObserver(self)
        points.1.removeObserver(self)
        points.2.removeObserver(self)
    }
}

class Polyhedron: Entity {
    let points: [Point]
    let edges:  [Edge]
    let faces:  [Triangle]

    init(points: [Point], edges: [Edge], faces: [Triangle], position: Vec4, color: NSColor) {
        self.points = points
        self.edges  = edges
        self.faces  = faces
        
        super.init(position: position, color: color)
    }
}

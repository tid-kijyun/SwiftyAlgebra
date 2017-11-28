//
//  Node.swift
//  Visualizer
//
//  Created by Taketo Sano on 2017/11/27.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Cocoa
import SceneKit

extension SCNNode {
    static func fromEntity(_ e: Entity) -> SCNNode {
        switch e {
        case let e as Point:
            return PointNode(e)
            
        case let e as Edge:
            return EdgeNode(e)
            
        case let e as Triangle:
            return TriangleNode(e)
            
        case let e as Polyhedron:
            let n = SCNNode()
            
            for p in e.points { n.addChildNode(fromEntity(p)) }
            for e in e.edges  { n.addChildNode(fromEntity(e)) }
            for f in e.faces  { n.addChildNode(fromEntity(f)) }
            
            return n
            
        default:
            return SCNNode()
        }
    }
}

class PointNode: SCNNode, EntityObserver {
    let entity: Point
    
    required init?(coder aDecoder: NSCoder) {
        self.entity = Point(position: Vec4.zero, color: .black) // TODO
        super.init(coder: aDecoder)
    }
    
    init(_ e: Point) {
        self.entity = e
        super.init()
        
        let s = SCNSphere(radius: 0.05)
        s.segmentCount = 8
        s.color = e.color
        
        self.geometry = s
        self.position = e.position.xyz
        
        e.addObserver(self)
    }
    
    func update(forEntity e: Entity) {
        self.position = e.position.xyz
    }
    
    deinit {
        entity.removeObserver(self)
    }
}

class EdgeNode: SCNNode, EntityObserver {
    let entity: Edge
    let p0: SCNNode
    let p1: SCNNode
    let cylinder: SCNNode
    
    required init?(coder aDecoder: NSCoder) {
        fatalError() // TODO
    }
    
    init(_ e: Edge) {
        let s = SCNCylinder(radius: 0.025, height: 0.1)
        s.radialSegmentCount = 6
        s.color = e.color
        
        let (p0, p1) = (SCNNode(), SCNNode())
        let z = SCNNode()
        z.eulerAngles.x = PI_2
        
        let c = SCNNode(geometry: s)
        z.addChildNode(c)
        
        p0.addChildNode(z)
        p0.constraints = [SCNLookAtConstraint(target: p1)]
        
        self.entity = e
        self.p0 = p0
        self.p1 = p1
        self.cylinder = c
        
        super.init()
        
        self.addChildNode(p0)
        self.addChildNode(p1)
        self.position = e.position.xyz
        
        update(forEntity: e)
        e.addObserver(self)
    }
    
    func update(forEntity _: Entity) {
        let v = entity.vector
        let h = v.xyz.length
        
        p0.position = (entity.points.0.position - entity.position).xyz
        p1.position = (entity.points.1.position - entity.position).xyz
        cylinder.position.y = -h / 2
        (cylinder.geometry! as! SCNCylinder).height = h
    }
    
    deinit {
        entity.removeObserver(self)
    }
}


class TriangleNode: SCNNode, EntityObserver {
    let entity: Triangle
    
    required init?(coder aDecoder: NSCoder) {
        fatalError() // TODO
    }
    
    init(_ e: Triangle) {
        self.entity = e
        super.init()
        
        let n = e.normalVector
        let vs = [e.points.0.xyz, e.points.1.xyz, e.points.2.xyz]
        let ns = Array(repeating: n, count: 3)
        let fs: [Int32] = [0, 1, 2]
        
        let vSource = SCNGeometrySource(vertices: vs)
        let nSource = SCNGeometrySource(normals:  ns)
        let fSource = SCNGeometryElement(indices: fs, primitiveType: .triangles)
        
        let g = SCNGeometry(sources: [vSource, nSource], elements: [fSource])
        g.color = e.color
        g.firstMaterial?.isDoubleSided = true
        
        self.geometry = g
        self.opacity = 0.5
        
        e.addObserver(self)
    }
    
    func update(forEntity _: Entity) {
        // TODO
    }
    
    deinit {
        entity.removeObserver(self)
    }
}

//
//  ForceDirecter.swift
//  Visualizer
//
//  Created by Taketo Sano on 2017/11/28.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import SceneKit

class ForceDirector {
    let l0: CGFloat = 1.0  // natural length
    let k : CGFloat = 3.0  // spring const
    let c : CGFloat = 3.0  // Coulomb const
    let d : CGFloat = 0.8  // decay
    let dt: CGFloat = 0.05
    let minE: CGFloat = 0.001
    
    let points: [Point]
    let center: Vec4
    
    var vel: [Vec4] // velocity of each point
    var i = 0 // iteration

    init(_ points: [Point], _ center: Vec4) {
        self.points = points
        self.center = center
        self.vel = Array(repeating: Vec4.zero, count: points.count)
    }
    
    func run(_ maxIterations: Int = 10000) {
        while itr() > minE && i < maxIterations {
            i += 1
        }
        centrize()
    }
    
    func itr() -> CGFloat {
        var E: CGFloat = 0     // total energy
        
        for (i, p) in points.enumerated() {
            
            var force = Vec4.zero
            
            // coulomb force
            if p.connectedEdges.count > 0 {
                force = force + points.reduce( Vec4.zero ) { (total, q) in
                    if p == q || q.connectedEdges.count == 0 { return total }
                    let v = p.position - q.position
                    let r = v.length
                    let f = c / (r * r) * v.normalized
                    return total + f
                }
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
        let b = points.map{ $0.position }.barycenter
        points.forEach{ p in p.position = p.position - b + center }
    }
}

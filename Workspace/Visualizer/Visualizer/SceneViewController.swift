//
//  ViewController.swift
//  Visualizer
//
//  Created by Taketo Sano on 2017/09/29.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Cocoa
import SceneKit

class SceneViewController : NSViewController {
    var wValue: CGFloat = 0
    
    var scene: SCNScene!
    @IBOutlet var sceneView:  SCNView!
    var cameraNode: SCNNode!
    var cameraTargetNode: SCNNode!
    var axesNode:   SCNNode!
    var objectsNode: SCNNode!
    
    // TODO create some entity struct
    var objects: [Visual] = [] {
        didSet {
            generateObjectNodes()
        }
    }
    
    @IBOutlet var slider: NSSlider!
    
    override func viewDidLoad() {
        setupScene()
    }
    
    private func setupScene() {
        scene = SCNScene()
        
        sceneView.scene = scene
        sceneView.autoenablesDefaultLighting = true
        
        cameraNode = {
            let cameraNode = SCNNode()
            let camera = SCNCamera()
            cameraNode.camera = {
                camera.usesOrthographicProjection = true
                camera.orthographicScale = 5
                return camera
            }()
            cameraNode.position = Vec3(20, 10, 20)
            return cameraNode
        }()
        
        scene.rootNode.addChildNode(cameraNode)
        
        // xyz-axis
        axesNode = {
            let axesNode = SCNNode()
            
            let dirs = [SCNVector4(0, 0, 1, -PI_2), SCNVector4.zero, SCNVector4(1, 0, 0, PI_2)]
            for d in dirs {
                let axis = SCNCylinder(radius: 0.01, height: 10)
                axis.color = .black
                axis.radialSegmentCount = 6
                let axisNode = SCNNode(geometry: axis)
                
                axisNode.rotation = d
                axesNode.addChildNode(axisNode)
                
                let cone = SCNCone(topRadius: 0, bottomRadius: 0.1, height: 0.2)
                cone.color = .black
                cone.radialSegmentCount = 6
                let coneNode = SCNNode(geometry: cone)
                coneNode.position = Vec3(0, 5, 0)
                axisNode.addChildNode(coneNode)
            }
            
            let originNode = SCNNode(geometry: {
                let origin = SCNSphere(radius: 0.1)
                origin.color = .black
                return origin
            }())
            
            axesNode.addChildNode(originNode)
            cameraTargetNode = originNode
            
            return axesNode
        }()
        
        scene.rootNode.addChildNode(axesNode)
        
        let target = SCNLookAtConstraint(target: cameraTargetNode)
        target.isGimbalLockEnabled = true
        cameraNode.constraints = [target]
        
        objectsNode = SCNNode()
        scene.rootNode.addChildNode(objectsNode)
    }
    
    func generateObjectNodes() {
        objectsNode.childNodes.forEach { n in
            n.removeFromParentNode()
        }
        
        func add(_ _e: Visual, to parent: SCNNode) {
            switch _e {
            case let e as Point:
                let n = pointNode(e)
                e.node = n
                parent.addChildNode(n)
                
            case let e as Edge:
                let n = edgeNode(e)
                e.node = n
                parent.addChildNode(n)
                break
                
            case let e as Polyhedron:
                let n = SCNNode()
                e.node = n
                parent.addChildNode(n)
                
                for p in e.points { add(p, to: n) }
                for e in e.edges  { add(e, to: n) }

            default:
                break
            }
        }
        
        objects.forEach { e in add(e, to: objectsNode) }
        updateObjects()
    }
    
    func updateObjects() {
        objects.forEach { e in
            switch e {
            case let p as Point:
                if let n = p.node {
                    n.opacity = (abs(p.w - wValue) < 1) ? exp(-pow(p.w - wValue, 2) * 15) : 0
                }
            default:
                break
            }
        }
    }
    
    private func pointNode(_ p: Point) -> SCNNode {
        return pointNode(p.xyz, p.color)
    }
    
    private func pointNode(_ pos: Vec3, _ color: NSColor = .black) -> SCNNode {
        let s = SCNSphere(radius: 0.05)
        s.segmentCount = 8
        s.color = color
        let n = SCNNode(geometry: s)
        n.position = pos
        return n
    }
    
    private func edgeNode(_ e: Edge) -> SCNNode {
        let v = e.vector
        let h = v.xyz.length
        
        let s = SCNCylinder(radius: 0.025, height: h)
        s.radialSegmentCount = 6
        s.color = e.color
        
        let n = SCNNode()
        n.position = e.position.xyz
        
        let (p0, p1) = (SCNNode(), SCNNode())
        p0.position = (e.points.0.position - e.position).xyz
        p1.position = (e.points.1.position - e.position).xyz
        n.addChildNode(p0)
        n.addChildNode(p1)
        
        let z = SCNNode()
        z.eulerAngles.x = PI_2
        
        let c = SCNNode(geometry: s)
        c.position.y = -h/2
        z.addChildNode(c)
        
        p0.addChildNode(z)
        p0.constraints = [SCNLookAtConstraint(target: p1)]
        
        return n
    }
    
    // interactions
    
    override func magnify(with event: NSEvent) {
        let camera = cameraNode.camera!
        let s = 5.0
        camera.orthographicScale = clamp(camera.orthographicScale - s * Double(event.magnification), 1.0, Double.infinity)
    }
    
    override func scrollWheel(with event: NSEvent) {
        let scale: CGFloat = 30.0
        let p = cameraNode.position
        let t = atan2(p.z, p.x) + event.deltaX / scale
        let s = clamp(atan2(p.y, len(p.x, p.z) ) + event.deltaY / scale, -PI_2, PI_2)
        cameraNode.position = 20 * Vec3(cos(s) * cos(t), sin(s), cos(s) * sin(t))
    }
    
    @IBAction func sliderMoved(target: NSSlider) {
        wValue = CGFloat(target.doubleValue)
        updateObjects()
    }
}

//
//  ViewController.swift
//  Visualizer
//
//  Created by Taketo Sano on 2017/09/29.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Cocoa
import SceneKit

class ViewController : NSViewController {
    var wValue: CGFloat = 0
    
    var scene: SCNScene!
    @IBOutlet var sceneView:  SCNView!
    var cameraNode: SCNNode!
    var cameraTargetNode: SCNNode!
    var axesNode:   SCNNode!
    var objectsNode: SCNNode!
    
    // TODO create some entity struct
    var objects: [(Vec4, NSColor)] = [] {
        didSet {
            generateObjectNodes()
        }
    }
    
    @IBOutlet var slider: NSSlider!
    
    override func viewDidLoad() {
        setupScene()
        objects = generateS3()
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
    
    // TODO move to some model class
    
    func generateS3(_ N: Int = 1000) -> [(Vec4, NSColor)] {
        return (0 ..< N).map { _ in (SCNVector4.random(-1 ... 1).normalized, .blue) }
    }
    
    func generateGL2(_ N: Int = 1000) -> [(Vec4, NSColor)] {
        return (0 ..< N).map { _ in
            let v = SCNVector4.random(-1 ... 1)
            let c: NSColor = (v.x * v.w - v.y * v.z > 0) ? .red : .blue
            return (v, c)
        }
    }
    
    // --TODO
    
    func generateObjectNodes() {
        objectsNode.childNodes.forEach { n in
            n.removeFromParentNode()
        }
        objects.forEach { (v, color) in
            let n = point(v.xyz, color)
            objectsNode.addChildNode(n)
        }
        updateObjects()
    }
    
    func updateObjects() {
        objects.enumerated().forEach { (i, e) in
            let v = e.0
            objectsNode.childNodes[i].opacity = (abs(v.w - wValue) < 1) ? exp(-pow(v.w - wValue, 2) * 15) : 0
        }
    }
    
    private func point(_ pos: Vec3, _ color: NSColor = .black) -> SCNNode {
        let s = SCNSphere(radius: 0.05)
        s.segmentCount = 8
        s.color = color
        let n = SCNNode(geometry: s)
        n.position = pos
        return n
    }
    
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

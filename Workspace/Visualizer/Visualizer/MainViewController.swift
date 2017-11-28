//
//  MainViewController.swift
//  Visualizer
//
//  Created by Taketo Sano on 2017/11/28.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Cocoa
import SwiftyAlgebra

private typealias Z = IntegerNumber

extension NSStoryboardSegue.Identifier {
    static let embeddedScene = NSStoryboardSegue.Identifier("EmbeddedScene")
}

extension NSUserInterfaceItemIdentifier {
    static let col0 = NSUserInterfaceItemIdentifier("Degree")
    static let col1 = NSUserInterfaceItemIdentifier("Generator")
    static let col2 = NSUserInterfaceItemIdentifier("Order")
}

class MainViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet var sceneViewController: SceneViewController!
    @IBOutlet var objectSelector: NSPopUpButton!
    @IBOutlet var tableView: NSTableView!
    
    let items   = ["Sphere", "Torus", "Mobius Strip", "Klein Bottle", "Projective Plane", "Lens Space"]
    let objects = [ { SimplicialComplex.sphere(dim: 2) },
                    { SimplicialComplex.circle(vertices: 3) × SimplicialComplex.circle(vertices: 6) },
                    { SimplicialComplex.mobiusStrip(circleVertices: 8, intervalVertices: 2) },
                    { SimplicialComplex.kleinBottle(circleVertices: 6) },
                    { SimplicialComplex.realProjectiveSpace(dim: 2) },
                    { SimplicialComplex.lensSpace(3) }

                  ]
    
    private typealias TableElement = (Int, String, String, [Simplex])
    private var tableData: [TableElement] = []
    private var polyhedron: Polyhedron!

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case .embeddedScene?:
            sceneViewController = segue.destinationController as! SceneViewController
            sceneViewController.loadView()
            sceneViewController.axesNode.isHidden = true
            selectObject(0)
            break
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        objectSelector.addItems(withTitles: items)
    }
    
    func selectObject(_ i: Int) {
        let K = objects[i]()
        polyhedron = Polyhedron(K)
        
        sceneViewController.objects = [ polyhedron ]
        
        let H = Homology(K, Z.self)
        tableData = (H.offset ... H.topDegree).flatMap{ i -> [TableElement] in
            return H[i].summands.map { s -> TableElement in
                let (a, r) = (s.generator, s.factor)
                return (i, a.description, r.description, a.basis)
            }
        }
        tableView.reloadData()
        tableView.deselectAll(nil)
    }
    
    func selectRow(_ i: Int) {
        let row = tableData[i]
        let (d, cycle) = (row.0, row.3)
        
        let entities = polyhedron.points.map{ $0 as Entity }
                     + polyhedron.edges .map{ $0 as Entity }
                     + polyhedron.faces .map{ $0 as Entity }
        
        for e in entities {
            if cycle.exists({ s in s.description == e.name }) {
                e.color = .red
            } else {
                e.color = .blue
            }
            e.didUpdate()
        }
    }
    
    func unselectRow() {
        let entities = polyhedron.points.map{ $0 as Entity }
            + polyhedron.edges .map{ $0 as Entity }
            + polyhedron.faces .map{ $0 as Entity }
        
        for e in entities {
            e.color = .blue
            e.didUpdate()
        }
    }
    
    // Delegates
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        switch tableColumn?.identifier {
        case .col0?:  return tableData[row].0
        case .col1?:  return tableData[row].1
        case .col2?:  return tableData[row].2
        default: return ""
        }
    }
    
    @IBAction func objectSelected(_ s: NSPopUpButton) {
        let i = s.indexOfSelectedItem
        selectObject(i)
    }
    
    @IBAction func tableRowSelected(_ t: NSTableView) {
        if t.selectedRow >= 0 {
            selectRow(t.selectedRow)
        } else {
            unselectRow()
        }
    }
}

//
//  PersistentHomology.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/10/23.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public struct PersistentHomology<K: Field> {
    public let complex: PersistentComplex
    public let homology: Homology<Polynomial<K>, Simplex>
    
    public init(_ filtration: [SimplicialComplex], _ type: K.Type) {
        self.complex = PersistentComplex(filtration)
        self.homology = Homology(complex.chainComplex(coeffType: K.self))
    }
    
    public func describe(_ i: Int) -> [(birthTime: Int, deathTime: Int?, generator: FreeModule<K, Simplex>)] {
        func birthTime(_ g: FreeModule<Polynomial<K>, Simplex>) -> Int {
            let (s, v) = g.elements.first{ $0.value != 0 }!
            return v.degree + complex.birthTime(of: s)!
        }
        
        func asCycle(_ g: FreeModule<Polynomial<K>, Simplex>) -> FreeModule<K, Simplex> {
            return FreeModule( g.map{ (s, v) in (v.leadCoeff, s) } )
        }
        
        return homology[i].summands.map{ e in
            switch e {
            case let .Free(generator: g):
                return (birthTime(g), nil, asCycle(g))
            case let .Tor(factor: r, generator: g):
                return (birthTime(g), birthTime(g) + r.degree, asCycle(g))
            }
        }
    }
    
    public var detailDescription: String {
        return (0 ... complex.dim).map { i in
            "\(i):" + describe(i).map{ (b, d, g) in
                "\t[\(b), \(d.flatMap{"\($0)"} ?? "∞")) : \(g)"
                }.joined(separator: ",\n")
            }.joined(separator: "\n\n")
    }
}

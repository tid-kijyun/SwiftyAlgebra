//
//  Persistence.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/10/22.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public struct PersistentComplex {
    public let filtration: [SimplicialComplex]
    public init(_ filtration: [SimplicialComplex]) {
        assert(!filtration.isEmpty)
        self.filtration = filtration
    }
    
    public var final: SimplicialComplex {
        return filtration.last!
    }
    
    public var dim: Int {
        return final.dim
    }
    
    func allCells(ofDim d: Int) -> [Simplex] {
        return final.allCells(ofDim: d)
    }
    
    func allCells(ascending a: Bool) -> [Simplex] {
        return final.allCells(ascending: a)
    }
    
    public func birthTime(of s: Simplex) -> Int? {
        return (0 ..< filtration.count).first{ t in
            filtration[t].contains(s)
        }
    }
    
    public func boundaryMap<K: Field>(_ i: Int) -> FreeModuleHom<Polynomial<K>, Simplex, Simplex> {
        typealias R = Polynomial<K>
        
        let from = allCells(ofDim: i)
        let to = (i > 0) ? allCells(ofDim: i - 1) : []
        let toIndex = Dictionary(pairs: to.enumerated().map{($1, $0)})
        
        let components = from.enumerated().flatMap{ (j, s1) -> [MatrixComponent<R>] in
            let t1 = birthTime(of: s1)!
            let boundary: FreeModule<K, Simplex> = s1.boundary()
            return boundary.map{ (e: (Simplex, K)) -> MatrixComponent<R> in
                let (s2, a) = e
                let i = toIndex[s2]!
                let t2 = birthTime(of: s2)!
                let value = a * R.monicTerm(ofDegree: t1 - t2)
                return (i, j, value)
            }
        }
        
        let matrix = DynamicMatrix(rows: to.count, cols: from.count, type: .Sparse, components: components)
        return FreeModuleHom(domainBasis: from, codomainBasis: to, matrix: matrix)
    }
    
    public func chainComplex<K: Field>(coeffType: K.Type) -> ChainComplex<Polynomial<K>, Simplex> {
        typealias R = Polynomial<K>
        typealias BoundaryMap = ChainComplex<R, Simplex>.BoundaryMap
        let chain = (0 ... dim).map{ (i) -> BoundaryMap in boundaryMap(i) }
        return ChainComplex(chain)
    }
}

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

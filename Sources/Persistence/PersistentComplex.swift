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

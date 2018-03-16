//
//  SymplecticGroup.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2018/03/16.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//
//  see: https://en.wikipedia.org/wiki/Symplectic_group

import Foundation

// Note <n> is the size of the matrix, thus must be even.

public struct SymplecticGroup<n: _Int, K: Field>: MatrixSubgroup {
    public typealias Super = GeneralLinearGroup<n, K>
    
    private let g: SquareMatrix<n, K>
    
    public init(_ g: SquareMatrix<n, K>) {
        assert(n.intValue.isEven)
        self.g = g
    }
    
    public var asMatrix: SquareMatrix<n, K> { return g }
    
    public static var standardSymplecticMatrix: SymplecticGroup<n, K> {
        let m = n.intValue / 2
        return SymplecticGroup { (i, j) in
            if i < m, j >= m, i == (j - m) {
                return -.identity
            } else if i >= m, j < m, (i - m) == j {
                return .identity
            } else {
                return .zero
            }
        }
    }
    
    public static func contains(_ g: GeneralLinearGroup<n, K>) -> Bool {
        let J = standardSymplecticMatrix.asSuper
        return g.transposed * J * g == J
    }
    
    public static var symbol: String  {
        return "Sp(\(n.intValue), \(K.symbol))"
    }
}
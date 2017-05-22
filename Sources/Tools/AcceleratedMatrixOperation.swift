//
//  AcceleratedMatrixOperation.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/05/22.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation
import Accelerate

private var _useAccelerate: Bool = true
public func useMatrixAcceleration(_ flag: Bool) {
    _useAccelerate = flag
}

public extension IntegerNumber {
    static var matrixOperation: BaseMatrixOperation<IntegerNumber> {
        if _useAccelerate {
            return AcceleratedIntegerMatrixOperation.sharedInstance
        } else {
            return BaseMatrixOperation<IntegerNumber>.sharedInstance
        }
    }
}

public class AcceleratedIntegerMatrixOperation: BaseMatrixOperation<IntegerNumber> {
    private static var _sharedInstance = AcceleratedIntegerMatrixOperation()
    override public class var sharedInstance: BaseMatrixOperation<IntegerNumber> {
        return _sharedInstance
    }
    private override init() {
        super.init()
    }
    
    public override func mul<n: _Int, m: _Int, p: _Int>(_ a: Matrix<IntegerNumber, n, m>, _ b: Matrix<IntegerNumber, m, p>) -> Matrix<IntegerNumber, n, p> {
        guard a.cols > 0 && b.cols > 0 else {
            return super.mul(a, b)
        }
        
        var grid: [Double] = Array(repeating: 0.0, count: a.rows * b.cols)
        cblas_dgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans,
                    Int32(a.rows), Int32(b.cols), Int32(a.cols),
                    1.0,
                    a.grid.map{Double($0)}, Int32(a.cols),
                    b.grid.map{Double($0)}, Int32(b.cols),
                    0.0,
                    &grid, Int32(b.cols))
        
        return Matrix<IntegerNumber, n, p>(rows: a.rows, cols: b.cols, grid: grid.map{ IntegerNumber(round($0)) })
    }
    
    // TODO implement more
}

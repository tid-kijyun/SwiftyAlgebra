//
//  Persistence.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/10/22.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public struct Persistence {
    public let filtration: [SimplicialComplex]
    public init(_ filtration: [SimplicialComplex]) {
        self.filtration = filtration
    }
    
    public func birthTime(of s: Simplex) -> Int? {
        return (0 ..< filtration.count).first{ t in
            filtration[t].contains(s)
        }
    }
}

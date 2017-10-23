//: Playground - noun: a place where people can play

import Foundation
import SwiftyAlgebra

// Aliases populary used in Math.

typealias Z = IntegerNumber
typealias Q = RationalNumber
typealias R = RealNumber

let V = VertexSet(count: 5)
let s = Simplex.generator(V)

let Ks = SimplicialComplex.filtration([
    [s(1, 2), s(2, 3), s(4)],
    [s(1, 4), s(3, 4)],
    [s(1, 3)],
    [s(1, 2, 3)],
    [s(1, 3, 4)]
])

let PH = PersistentHomology(Ks, Z_2.self)
print(PH.detailDescription)

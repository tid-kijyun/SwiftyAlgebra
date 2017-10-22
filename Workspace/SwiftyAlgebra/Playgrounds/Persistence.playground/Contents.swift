//: Playground - noun: a place where people can play

import Foundation
import SwiftyAlgebra

// Aliases populary used in Math.

typealias Z = IntegerNumber
typealias Q = RationalNumber
typealias R = RealNumber

let V = VertexSet(count: 4)
let s = Simplex.generator(V)

let Ks = SimplicialComplex.filtration([
    [s(0, 1), s(1, 2), s(3)],
    [s(0, 3), s(2, 3)],
    [s(0, 2)],
    [s(0, 1, 2)],
    [s(0, 2, 3)]
])

let PH = Persistence(Ks)

PH.birthTime(of: s(0))
PH.birthTime(of: s(0, 1, 2))
PH.birthTime(of: s(0, 1, 3))




import Foundation

precedencegroup ExponentiativePrecedence {
    associativity: right
    higherThan: MultiplicationPrecedence
}

infix operator **: ExponentiativePrecedence

public protocol Monoid: SetType {
    static func * (a: Self, b: Self) -> Self
    static var identity: Self { get }
}

public extension Monoid {
    public static func ** (a: Self, b: Int) -> Self {
        return b == 0 ? Self.identity : a * (a ** (b - 1))
    }
}

public protocol Submonoid: Monoid, SubsetType {
    associatedtype Super: Monoid
}

public extension Submonoid {
    static var identity: Self {
        return Self.init(Super.identity)
    }
    
    public static func * (a: Self, b: Self) -> Self {
        return Self.init(a.asSuper * b.asSuper)
    }
}

public protocol _ProductMonoid: Monoid, ProductSetType {
    associatedtype Left: Monoid
    associatedtype Right: Monoid
}

public extension _ProductMonoid {
    public static var identity: Self {
        return Self.init(Left.identity, Right.identity)
    }
    
    public static func * (a: Self, b: Self) -> Self {
        return Self.init(a._1 * b._1, a._2 * b._2)
    }
}

public struct ProductMonoid<M1: Monoid, M2: Monoid>: _ProductMonoid {
    public typealias Left = M1
    public typealias Right = M2
    
    public let _1: M1
    public let _2: M2
    
    public init(_ m1: M1, _ m2: M2) {
        self._1 = m1
        self._2 = m2
    }
}

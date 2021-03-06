import Foundation

public protocol Monoid: SetType {
    static func * (a: Self, b: Self) -> Self
    static var identity: Self { get }
    func pow(_ n: 𝐙) -> Self
}

public extension Monoid {
    public func pow(_ n: 𝐙) -> Self {
        assert(n >= 0)
        return (0 ..< n).reduce(.identity){ (res, _) in self * res }
    }
}

public protocol Submonoid: Monoid, SubsetType where Super: Monoid {}

public extension Submonoid {
    static var identity: Self {
        return Self(Super.identity)
    }
    
    public static func * (a: Self, b: Self) -> Self {
        return Self(a.asSuper * b.asSuper)
    }
}

public protocol _ProductMonoid: Monoid, ProductSetType where Left: Monoid, Right: Monoid {}

public extension _ProductMonoid {
    public static var identity: Self {
        return Self(Left.identity, Right.identity)
    }
    
    public static func * (a: Self, b: Self) -> Self {
        return Self(a._1 * b._1, a._2 * b._2)
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

public protocol _MonoidHom: Map where Domain: Monoid, Codomain: Monoid {}

public struct MonoidHom<X: Monoid, Y: Monoid>: _MonoidHom {
    public typealias Domain = X
    public typealias Codomain = Y
    
    private let f: (X) -> Y
    public init(_ f: @escaping (X) -> Y) {
        self.f = f
    }
    
    public func applied(to x: X) -> Y {
        return f(x)
    }
    
    public func composed<W>(with f: MonoidHom<W, X>) -> MonoidHom<W, Y> {
        return MonoidHom<W, Y> { x in self.applied(to: f.applied(to: x)) }
    }
    
    public static func ∘<Z>(g: MonoidHom<Y, Z>, f: MonoidHom<X, Y>) -> MonoidHom<X, Z> {
        return g.composed(with: f)
    }
}

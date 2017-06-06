import Foundation

public protocol Ring: AdditiveGroup, Monoid, ExpressibleByIntegerLiteral {
    associatedtype IntegerLiteralType = IntegerNumber
    init(intValue: IntegerNumber)
    var isUnit: Bool { get }
    var unitInverse: Self? { get }
    static func matrixElimination<n:_Int, m:_Int>(_ A: Matrix<Self, n, m>, mode: MatrixEliminationMode) -> BaseMatrixElimination<Self, n, m>
}

public extension Ring {
    // required init from `ExpressibleByIntegerLiteral`
    public init(integerLiteral value: IntegerNumber) {
        self.init(intValue: value)
    }
    
    public static var zero: Self {
        return Self.init(intValue: 0)
    }
    
    public static var identity: Self {
        return Self.init(intValue: 1)
    }
    
    public static func **(a: Self, n: Int) -> Self {
        return (0 ..< n).reduce(Self.identity){ (res, _) in res * a }
    }
    
    // must override in subclass
    public static func matrixElimination<n:_Int, m:_Int>(_ A: Matrix<Self, n, m>, mode: MatrixEliminationMode) -> BaseMatrixElimination<Self, n, m> {
        return BaseMatrixElimination<Self, n, m>(A, mode: mode)
    }
}

public protocol Subring: Ring, AdditiveSubgroup, Submonoid {
    associatedtype Super: Ring
}

public protocol Ideal: AdditiveGroup, AdditiveSubgroup {
    associatedtype Super: Ring
    static func * (r: Super, a: Self) -> Self
    static func * (m: Self, r: Super) -> Self
    
    static func reduced(_ a: Super) -> Super
    static func isUnitInQuotient(_ r: Super) -> Bool
    static func inverseInQuotient(_ r: Super) -> Super?
}

public extension Ideal {
    public static func * (a: Self, b: Self) -> Self {
        return Self.init(a.asSuper * b.asSuper)
    }
    
    public static func * (r: Super, a: Self) -> Self {
        return Self.init(r * a.asSuper)
    }
    
    public static func * (a: Self, r: Super) -> Self {
        return Self.init(a.asSuper * r)
    }
}

public protocol _ProductRing: Ring, AdditiveProductGroup {
    associatedtype Left: Ring
    associatedtype Right: Ring
}

public extension _ProductRing {
    public init(intValue a: Int) {
        self.init(Left(intValue: a), Right(intValue: a))
    }
    
    public var isUnit: Bool {
        return _1.isUnit && _2.isUnit
    }
    
    public var unitInverse: Self? {
        return isUnit ? Self.init(_1.unitInverse!, _2.unitInverse!) : nil
    }
    
    public static var zero: Self {
        return Self(Left.zero, Right.zero)
    }
    public static var identity: Self {
        return Self(Left.identity, Right.identity)
    }
    
    public static func * (a: Self, b: Self) -> Self {
        return Self(a._1 * b._1, a._2 * b._2)
    }
}

public struct ProductRing<R1: Ring, R2: Ring>: _ProductRing {
    public typealias Left = R1
    public typealias Right = R2
    
    public let _1: R1
    public let _2: R2
    
    public init(_ r1: R1, _ r2: R2) {
        self._1 = r1
        self._2 = r2
    }
}

public protocol _QuotientRing: Ring, AdditiveQuotientGroup {
    associatedtype Sub: Ideal
}

public extension _QuotientRing where Base == Sub.Super {
    public init(intValue n: Int) {
        self.init(Base(intValue: n))
    }
    
    public var isUnit: Bool {
        return Sub.isUnitInQuotient(representative)
    }
    
    public var unitInverse: Self? {
        return Sub.inverseInQuotient(representative).map{ Self.init($0) }
    }
    
    public static var zero: Self {
        return Self.init(Base.zero)
    }
    
    public static var identity: Self {
        return Self.init(Base.identity)
    }
    
    public static func * (a: Self, b: Self) -> Self {
        return Self.init(a.representative * b.representative)
    }
    
    public var hashValue: Int {
        return representative.hashValue // must assure `representative` is unique.
    }
}

public struct QuotientRing<R: Ring, I: Ideal>: _QuotientRing where R == I.Super {
    public typealias Sub = I
    
    internal let r: R
    
    public init(_ r: R) {
        self.r = I.reduced(r)
    }
    
    public var representative: R {
        return r
    }
}

public protocol _QuotientField: Field, _QuotientRing { }

public extension _QuotientField where Base == Sub.Super {
    public var isUnit: Bool {
        return Sub.isUnitInQuotient(representative)
    }
    
    public var unitInverse: Self? {
        return Sub.inverseInQuotient(representative).map{ Self.init($0) }
    }
    
    public var inverse: Self {
        return unitInverse!
    }
}

// TODO merge with QuotientRing after conditional conformance is supported.
public struct QuotientField<R: Ring, I: Ideal>: _QuotientField where R == I.Super {
    public typealias Sub = I
    
    internal let r: R
    
    public init(_ r: R) {
        self.r = I.reduced(r)
    }
    
    public var representative: R {
        return r
    }
}

import Foundation

public protocol AdditiveGroup: SetType {
    static func + (a: Self, b: Self) -> Self
    prefix static func - (x: Self) -> Self
    static var zero: Self { get }
    static var symbol: String { get }
}

public extension AdditiveGroup {
    public static func -(a: Self, b: Self) -> Self {
        return (a + (-b))
    }
}

public protocol AdditiveSubgroup: AdditiveGroup, SubsetType {
    associatedtype Super: AdditiveGroup
}

public extension AdditiveSubgroup {
    public static var zero: Self {
        return Self.init(Super.zero)
    }
    
    public static func + (a: Self, b: Self) -> Self {
        return Self.init(a.asSuper + b.asSuper)
    }
    
    prefix static func - (a: Self) -> Self {
        return Self.init(a.asSuper)
    }
}

public protocol AdditiveProductGroup: AdditiveGroup, ProductSetType {
    associatedtype Left: AdditiveGroup
    associatedtype Right: AdditiveGroup
}

public extension AdditiveProductGroup {
    public static var zero: Self {
        return Self(Left.zero, Right.zero)
    }
    
    public static func + (a: Self, b: Self) -> Self {
        return Self(a._1 + b._1, a._2 + b._2)
    }
    
    public static prefix func - (a: Self) -> Self {
        return Self(-a._1, -a._2)
    }
}

public protocol AdditiveQuotientGroup: AdditiveGroup, QuotientSetType {
    associatedtype Sub: AdditiveSubgroup
}

public extension AdditiveQuotientGroup where Base == Sub.Super {
    public static func isEquivalent(_ a: Base, _ b: Base) -> Bool {
        return Sub.contains( a - b )
    }
    
    public static var zero: Self {
        return Self.init(Base.zero)
    }
    
    public static func + (a: Self, b: Self) -> Self {
        return Self.init(a.representative + b.representative)
    }
    
    public static prefix func - (a: Self) -> Self {
        return Self.init(-a.representative)
    }
}

import Foundation

// AlgExtension: returns the factory for generating an PolynomialQuotient element.
// use as:
//
// let K = AlgExtension( Polynomial<Q>(1, 0, 1) )  // K = Q[x]/(x^2 + 1)
// let a = K( Polynomial(0, 1) )                   // a = x mod x^2 + 1
// a == -1                                         // true
public func AlgExtension<K: Field>(_ divisor: Polynomial<K>) -> ((Polynomial<K>) -> PolynomialQuotient<K>) {
    return { (value: Polynomial<K>) in PolynomialQuotient<K>(value: value, mod: divisor) }
}

public struct PolynomialQuotient<K: Field>: EuclideanQuotientField {
    public typealias R = Polynomial<K>
    public let value: R
    public let mod: R
    
    public init(value: Polynomial<K>, mod: Polynomial<K>) {
        // TODO must check the irreducibility of `mod` for this type to be a field.
        self.value = value
        self.mod = mod
    }
    
    public init(_ value: R) {
        self.value = value
        self.mod = 1
    }
    
    public var inverse: PolynomialQuotient<K> {
        // find: f * p + m * q = r (r: const)
        // then: f^-1 = r^-1 * p (mod m)
        
        let (p, _, r) = bezout(value, mod)
        if r == 0 || r.degree > 0 {
            fatalError("\(value) and \(mod) is not coprime.")
        }
        
        return PolynomialQuotient(value: R(r.coeff(0).inverse) * p, mod: mod)
    }
    
    private static func commonMod(_ a: Polynomial<K>, _ b: Polynomial<K>) -> Polynomial<K> {
        switch(a, b) {
        case (_, 1): return a
        case (1, _): return b
        case _ where a == b: return a
        default: fatalError("")
        }
    }
    
    static public func ==(a: PolynomialQuotient<K>, b: PolynomialQuotient<K>) -> Bool {
        return (a.value - b.value) % commonMod(a.mod, b.mod) == 0
    }

    static public func +(a: PolynomialQuotient<K>, b: PolynomialQuotient<K>) -> PolynomialQuotient<K> {
        return PolynomialQuotient<K>(value: a.value + b.value, mod: commonMod(a.mod, b.mod))
    }
    
    static public prefix func -(a: PolynomialQuotient<K>) -> PolynomialQuotient<K> {
        return PolynomialQuotient<K>(value: -a.value, mod: a.mod)
    }
    
    static public func *(a: PolynomialQuotient<K>, b: PolynomialQuotient<K>) -> PolynomialQuotient<K> {
        return PolynomialQuotient<K>(value: a.value * b.value, mod: commonMod(a.mod, b.mod))
    }
}

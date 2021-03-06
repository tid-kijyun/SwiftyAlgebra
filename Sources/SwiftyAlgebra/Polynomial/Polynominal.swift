import Foundation

// concrete Polynomial-type over a field

// TODO after Swift4,
// make `K: Ring`, and conform to `EuclideanRing` only when `K: Field`
public struct Polynomial<K: Field>: EuclideanRing, Module {
    public typealias CoeffRing = K
    internal let coeffs: [K]
    
    public init(from n: 𝐙) {
        let a = K(from: n)
        self.init(coeffs: [a])
    }
    
    public init(coeffs: [K]) {
        assert(coeffs.count > 0)
        if coeffs.last! == .zero {
            let dropped = coeffs.dropLast{ $0 == K.zero }.toArray()
            self.coeffs = dropped.isEmpty ? [.zero] : dropped
        } else {
            self.coeffs = coeffs
        }
    }
    
    public init(_ coeffs: K...) {
        self.init(coeffs: coeffs)
    }
    
    public init(degree: Int, gen: ((Int) -> K)) {
        let coeffs = (0 ... degree).map(gen)
        self.init(coeffs: coeffs)
    }
    
    public var normalizeUnit: Polynomial<K> {
        return Polynomial(leadCoeff.inverse!)
    }
    
    public var degree: Int {
        return coeffs.count - 1
    }
    
    public var inverse: Polynomial<K>? {
        return (degree == 0 && self != 0) ? Polynomial<K>(coeff(0).inverse!) : nil
    }
    
    public var leadCoeff: K {
        return coeffs[degree]
    }
    
    public func coeff(_ i: Int) -> K {
        return i < coeffs.count ? coeffs[i] : 0
    }
    
    // Horner's method
    // see: https://en.wikipedia.org/wiki/Horner%27s_method
    public func evaluate(_ x: K) -> K {
        return (0 ..< degree).reversed().reduce(leadCoeff) { (res, i) in
            coeff(i) + x * res
        }
    }
    
    // MEMO: more generally, this could be done with any superring of K.
    public func evaluate<n>(_ x: SquareMatrix<n, K>) -> SquareMatrix<n, K> {
        typealias M = SquareMatrix<n, K>
        return (0 ..< degree).reversed().reduce(leadCoeff * M.identity) { (res, i) -> M in
            M(scalar: coeff(i)) + x * res // <- the compiler complains that this is too complex...
        }
    }
    
    public func mapCoeffs(_ f: ((K) -> K)) -> Polynomial<K> {
        return Polynomial<K>(coeffs: coeffs.map(f))
    }
    
    public var derivative: Polynomial<K> {
        return Polynomial<K>.init(degree: degree - 1) {
            K(from: $0 + 1) * coeff($0 + 1)
        }
    }
    
    public func toMonic() -> Polynomial<K> {
        let a = leadCoeff
        return self.mapCoeffs{ $0 / a }
    }
    
    public static var indeterminate: Polynomial<K> {
        return Polynomial<K>(0, 1)
    }
    
    public static func eucDiv<K>(_ f: Polynomial<K>, _ g: Polynomial<K>) -> (q: Polynomial<K>, r: Polynomial<K>) {
        if g == 0 {
            fatalError("divide by 0")
        }
        
        func eucDivMonomial(_ f: Polynomial<K>, _ g: Polynomial<K>) -> (q: Polynomial<K>, r: Polynomial<K>) {
            let n = f.degree - g.degree
            
            if n < 0 {
                return (0, f)
            } else {
                let x = Polynomial<K>.indeterminate
                let a = f.leadCoeff / g.leadCoeff
                let q = a * x.pow(n)
                let r = f - q * g
                return (q, r)
            }
        }
        
        return (0 ... max(0, f.degree - g.degree))
            .reversed()
            .reduce( (0, f) ) { (result: (Polynomial<K>, Polynomial<K>), degree: Int) in
                let (q, r) = result
                let m = eucDivMonomial(r, g)
                return (q + m.q, m.r)
        }
    }
    
    public static func == (f: Polynomial<K>, g: Polynomial<K>) -> Bool {
        return (f.degree == g.degree) &&
            (0 ... f.degree).reduce(true) { $0 && (f.coeff($1) == g.coeff($1)) }
    }
    
    public static func + (f: Polynomial<K>, g: Polynomial<K>) -> Polynomial<K> {
        return Polynomial<K>(degree: max(f.degree, g.degree)) { f.coeff($0) + g.coeff($0) }
    }
    
    public static prefix func - (f: Polynomial<K>) -> Polynomial<K> {
        return f.mapCoeffs { -$0 }
    }
    
    public static func * (f: Polynomial<K>, g: Polynomial<K>) -> Polynomial<K> {
        return Polynomial<K>(degree: f.degree + g.degree) {
            (k: Int) in
            (max(0, k - g.degree) ... min(k, f.degree)).reduce(0) {
                (res:K, i:Int) in res + f.coeff(i) * g.coeff(k - i)
            }
        }
    }
    
    public static func * (r: K, f: Polynomial<K>) -> Polynomial<K> {
        return f.mapCoeffs { r * $0 }
    }
    
    public static func * (f: Polynomial<K>, r: K) -> Polynomial<K> {
        return f.mapCoeffs { $0 * r }
    }
    
    public var description: String {
        return Format.terms("+", coeffs.enumerated().reversed().map{(n, a) in (a, "x", n)}, skipZero: true)
    }
    
    public static var symbol: String {
        return "\(K.symbol)[x]"
    }
    
    public var hashValue: Int {
        return leadCoeff.hashValue
    }
}


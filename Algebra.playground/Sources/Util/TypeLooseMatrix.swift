import Foundation

// Matrix-struct without size constraints.
// Used only for computation.

public struct TypeLooseMatrix<R: Ring>: Equatable {
    public let rows: Int
    public let cols: Int
    
    fileprivate var elements: [R]
    
    private func index(_ i: Int, _ j: Int) -> Int {
        return (i * cols) + j
    }
    
    public subscript(i: Int, j: Int) -> R {
        get {
            return elements[index(i, j)]
        }
        set {
            elements[index(i, j)] = newValue
        }
    }
    
    private init(rows: Int, cols: Int, elements: [R]) {
        self.rows = rows
        self.cols = cols
        self.elements = elements
    }
    
    public init(rows: Int, cols: Int, elements: R...) {
        self.init(rows: rows, cols: cols, elements: elements)
    }
    
    public init(rows: Int, cols: Int, _ gen: (Int, Int) -> R) {
        let elements = (0 ..< rows * cols).map { gen($0 / rows, $0 % cols) }
        self.init(rows: rows, cols: cols, elements: elements)
    }
}

extension TypeLooseMatrix: CustomStringConvertible {
    public var description: String {
        return "[" + (0 ..< rows).map({ i in
            return (0 ..< cols).map({ j in
                return "\(self[i, j])"
            }).joined(separator: ", ")
        }).joined(separator: "\n ") + "]"
    }
}

public func == <R: Ring>(a: TypeLooseMatrix<R>, b: TypeLooseMatrix<R>) -> Bool {
    if (a.rows, a.cols) != (b.rows, b.cols) {
        return false
    }
    
    for i in 0 ..< a.rows {
        for j in 0 ..< a.cols {
            if a[i, j] != b[i, j] {
                return false
            }
        }
    }
    
    return true
}

public func + <R: Ring>(a: TypeLooseMatrix<R>, b: TypeLooseMatrix<R>) -> TypeLooseMatrix<R> {
    guard (a.rows, a.cols) == (b.rows, b.cols) else {
        fatalError()
    }
    
    return TypeLooseMatrix<R>(rows: a.rows, cols: a.cols) { (i, j) -> R in
        return a[i, j] + b[i, j]
    }
}

public prefix func -<R: Ring>(a: TypeLooseMatrix<R>) -> TypeLooseMatrix<R> {
    return TypeLooseMatrix<R>(rows: a.rows, cols: a.cols){ (i, j) -> R in
        return -a[i, j]
    }
}

public func - <R: Ring>(a: TypeLooseMatrix<R>, b: TypeLooseMatrix<R>) -> TypeLooseMatrix<R> {
    guard (a.rows, a.cols) == (b.rows, b.cols) else {
        fatalError()
    }
    
    return TypeLooseMatrix<R>(rows: a.rows, cols: a.cols){ (i, j) -> R in
        return a[i, j] - b[i, j]
    }
}

public func * <R: Ring>(r: R, a: TypeLooseMatrix<R>) -> TypeLooseMatrix<R> {
    return TypeLooseMatrix<R>(rows: a.rows, cols: a.cols) { (i, j) -> R in
        return r * a[i, j]
    }
}

public func * <R: Ring>(a: TypeLooseMatrix<R>, r: R) -> TypeLooseMatrix<R> {
    return TypeLooseMatrix<R>(rows: a.rows, cols: a.cols) { (i, j) -> R in
        return a[i, j] * r
    }
}

public func * <R: Ring>(a: TypeLooseMatrix<R>, b: TypeLooseMatrix<R>) -> TypeLooseMatrix<R> {
    guard a.cols == b.rows else {
        fatalError()
    }
    
    return TypeLooseMatrix<R>(rows: a.rows, cols: b.cols) { (i, k) -> R in
        return (0 ..< a.cols)
            .map({j in a[i, j] * b[j, k]})
            .reduce(0) {$0 + $1}
    }
}

public func det<R: Ring>(_ a: TypeLooseMatrix<R>) -> R {
    guard a.rows == a.cols else {
        fatalError()
    }
    
    let n = a.rows
    return perm(n).reduce(0) {
        (res: R, s: [Int]) -> R in
        res + R(sgn(s)) * (0 ..< n).reduce(1) {
            (p: R, i: Int) -> R in
            p * a[i, s[i]]
        }
    }
}

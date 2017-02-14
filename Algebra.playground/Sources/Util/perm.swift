import Foundation

public func perm(_ n: Int) -> [[Int]] {
    switch n {
    case 0:
        return [[]]
    default:
        let prev = perm(n - 1)
        return (0 ..< n).flatMap({ (i: Int) -> [[Int]] in
            prev.map({ (s: [Int]) -> [Int] in
                [i] + s.map{ $0 < i ? $0 : $0 + 1 }
            })
        })
    }
}

public func sgn(_ s: [Int]) -> Int {
    switch s.count {
    case 0, 1:
        return 1
    case let l:
        let r = (0 ..< l - 1)
            .flatMap{ i in (i + 1 ..< l).map{ j in (i, j) } }
            .reduce((1, 1)) {
                (r: (Int, Int), pair: (Int, Int)) -> (Int, Int) in
                return (r.0 * (pair.0 - pair.1) , r.1 * (s[pair.0] - s[pair.1]))
        }
        return r.0 / r.1
    }
}

import Foundation

public typealias RealNumber = Double

extension RealNumber: Field {
    public init(_ q: RationalNumber) {
        self.init(RealNumber(q.numerator) / RealNumber(q.denominator))
    }
    
    public var inverse: RealNumber {
        return 1 / self
    }
}

import Foundation

public struct RegDate: Codable {
    public let from: Int64
    public let to: Int64
    public let validUntil: Int64

    public init(from: Int64, to: Int64, validUntil: Int64) {
        self.from = from
        self.to = to
        self.validUntil = validUntil
    }
}

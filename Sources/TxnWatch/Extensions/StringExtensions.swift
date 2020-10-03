import Foundation

extension StringProtocol {
    var drop0xPrefix: SubSequence { hasPrefix("0x") ? dropFirst(2) : self[...] }
    var drop0bPrefix: SubSequence { hasPrefix("0b") ? dropFirst(2) : self[...] }
    var hexaToDecimal: Int { Int(drop0xPrefix, radix: 16) ?? 0 }
    var hexaToBinary: String { .init(hexaToDecimal, radix: 2) }
    var decimalToHexa: String { .init(Int(self) ?? 0, radix: 16) }
    var decimalToBinary: String { .init(Int(self) ?? 0, radix: 2) }
    var binaryToDecimal: Int { Int(drop0bPrefix, radix: 2) ?? 0 }
    var binaryToHexa: String { .init(binaryToDecimal, radix: 16) }
}

extension String {
    func components(withLength length: Int) -> [String] {
        return stride(from: 0, to: self.count, by: length).map {
            let start = self.index(self.startIndex, offsetBy: $0)
            let end = self.index(start, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            return String(self[start..<end])
        }
    }

    var hexadecimal: Data? {
        var data = Data(capacity: self.count / 2)

        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }

        guard data.count > 0 else { return nil }

        return data
    }
    
    init?(hexadecimal string: String, encoding: String.Encoding = .utf8) {
        guard let data = string.hexadecimal else {
            return nil
        }

        self.init(data: data, encoding: encoding)
    }

}


extension Data {

    /// Hexadecimal string representation of `Data` object.

    var hexadecimal: String {
        return map { String(format: "%02x", $0) }
            .joined()
    }

    var uint64: UInt64 {
          get {
              if count >= 8 {
                  return self.withUnsafeBytes { $0.load(as: UInt64.self).bigEndian }
              } else {
                  return (Data(repeating: 0, count: 8 - count) + self).uint64
              }
          }
      }

}



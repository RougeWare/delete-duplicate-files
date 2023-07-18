//
//  Data + hex.swift
//  DeleteDuplicateFiles
//
//  Created by S🌟System on 2022-07-26.
//

import Foundation

import StringIntegerAccess



public extension Data {
    
    /// Creates a new `Data` instance from the given hex-encoded string
    ///
    /// This assumes the input is well-formed. This means that any non-hex characters are skipped, and if the given string is an odd number of characters, the last character is ignored.
    ///
    /// Hex characters are `0123456789abcdefgABCDEFG`
    ///
    /// - Parameter hexString: A hex-encoded string. Must be an even number of hex chaacters
    init(hexEncoded hexString: String) {
        self.init(hexString
            .lazy
            .compactMap { charToHexMap[$0] }
            .inGroups(of: 2)
            .filter { $0.count == 2 }
            .map { asciiPair in
                (asciiPair.first! << 4)
                | asciiPair.last!
            }
        )
    }
}



let asciiToHexMap: [Unicode.ASCII.CodeUnit : Data.Element] =
    .init(uniqueKeysWithValues: zip(charToHexMap.keys.compactMap { $0.asciiValue },
                                    charToHexMap.values))



let charToHexMap: [Character : Data.Element] = [
    "0" : 0x00, "1" : 0x01, "2" : 0x02, "3" : 0x03, "4" : 0x04,
    "5" : 0x05, "6" : 0x06, "7" : 0x07, "8" : 0x08, "9" : 0x09,
    
    "a" : 0x0a, "b" : 0x0b, "c" : 0x0c, "d" : 0x0d, "e" : 0x0e, "f" : 0x0f,
    "A" : 0x0A, "B" : 0x0B, "C" : 0x0C, "D" : 0x0D, "E" : 0x0E, "F" : 0x0F,
]



//public extension Data {
//    // Adapted from https://gist.github.com/vi/dd3b5569af8a26b97c8e20ae06e804cb
//    init(hexEncoded str: String) {
//        /// Required in order to type-check this expression in reasonable time
//        let evensOnly = (0 ..< str.count/2)
//            .lazy
//            .filter(\.isEven)
//
//        self = evensOnly.reduce(into: Data(count: str.count/2)) { bytes, index in
//                bytes[index/2] = (asciiToHexMap[Int((str[index+0].utf8.first! & 0x1F) ^ 0x10)] << 4)
//                              | asciiToHexMap[Int((str[index+1].utf8.first! & 0x1F) ^ 0x10)]
//            }
//    }
//}
//
//
//
///// mapping of ASCII characters to hex values
//let asciiToHexMap: [UInt8] = [
//    0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, // 01234567
//    0x08, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // 89:;<=>?
//    0x00, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x00, // @ABCDEFG
//    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // HIJKLMNO
//]



private extension BinaryInteger {
    var isEven: Bool {
        (self % 2) == 0
    }
}



extension Collection {
    func inGroups(of maxLength: Int) -> UnfoldSequence<SubSequence,Index> {
        sequence(state: startIndex) { start in
            guard start < self.endIndex else { return nil }
            let end = self.index(start, offsetBy: maxLength, limitedBy: self.endIndex) ?? self.endIndex
            defer { start = end }
            return self[start..<end]
        }
    }
}










extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return self.map { String(format: format, $0) }.joined()
    }
}

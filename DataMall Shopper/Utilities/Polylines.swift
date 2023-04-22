//
//  Polylines.swift
//  DataMall Shopper
//
//  Created by 堅書 on 2023/04/22.
//

import CoreLocation
import Foundation

func roundToFive(_ double: Double) -> Double {
    return round(double * 100000) / 100000
}

func encode(_ coordinate: CLLocationCoordinate2D) -> String {
    return encode(coordinate.latitude) + encode(coordinate.longitude)
}

// Encoded polyline algorithm from https://developers.google.com/maps/documentation/utilities/polylinealgorithm
func encode(_ original: Double) -> String {
    var point = UInt32(abs(Int((original * 100000).rounded())))
    if original < 0 {
        point = ~point + 1
    }
    point <<= 1
    if original < 0 {
        point = ~point
    }
    var chunks: [UInt8] = []
    for bitIndex in stride(from: 0, to: 32, by: 5) {
        let chunk = (point >> bitIndex)  & 0b11111
        chunks.append(UInt8(chunk))
    }
    repeat {
        chunks.removeLast()
    } while chunks.last == 0b0 && chunks.count > 1
    for index in 0..<(chunks.count - 1) {
        chunks[index] = chunks[index] | 0x20
    }
    var decimals: [Int] = []
    chunks.forEach { uint8 in
        decimals.append(Int(uint8))
    }
    for index in 0..<decimals.count {
        decimals[index] += 63
    }
    var finalString: String = ""
    decimals.forEach { int in
        let asciiCharacter = String(UnicodeScalar(int)!)
        finalString += asciiCharacter
    }
    return finalString
}

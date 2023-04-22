//
//  JSONUtilities.swift
//  Buses
//
//  Created by 堅書 on 2022/04/11.
//

import Foundation

func encode<T: Encodable>(_ object: T) -> String? {
    do {
        let jsonData = try JSONEncoder().encode(object)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        return jsonString
    } catch {
        print("Error while encoding an object: \(error.localizedDescription)")
    }
    return nil
}

func decode<T: Decodable>(from path: String) -> T? {
    do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        return decode(fromData: data)
    } catch {
        print("Error while decoding an object: \(error.localizedDescription)")
    }
    return nil
}

func decode<T: Decodable>(fromData data: Data) -> T? {
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch let DecodingError.dataCorrupted(context) {
        print("Error while decoding an object: \(context.debugDescription)\n" +
            "Coding Path: \(context.codingPath.description)\n" +
            "Underlying Error: \(context.underlyingError?.localizedDescription ?? "(none)")")
    } catch let DecodingError.keyNotFound(key, context) {
        print("Error while decoding an object: \(context.debugDescription)\n" +
            "Key: \(key)\nCoding Path: \(context.codingPath.description)")
    } catch let DecodingError.valueNotFound(value, context) {
        print("Error while decoding an object: \(context.debugDescription)\n" +
            "Value: \(value)\nCoding Path: \(context.codingPath.description)")
    } catch let DecodingError.typeMismatch(type, context) {
        print("Error while decoding an object: \(context.debugDescription)\n" +
            "Type: \(type)\nCoding Path: \(context.codingPath.description)")
    } catch {
        print("Error while decoding an object: \(error.localizedDescription)")
    }
    print(String(data: data, encoding: .utf8) ?? "No content found.")
    return nil
}

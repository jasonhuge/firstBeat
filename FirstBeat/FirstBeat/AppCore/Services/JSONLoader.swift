//
//  JSONLoader.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/2/26.
//

import Foundation

struct JSONLoader {
    static func load<T: Decodable>(_ type: T.Type = T.self, filename: String) -> T? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("❌ Failed to locate \(filename).json in bundle")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            return try decoder.decode(T.self, from: data)
        } catch {
            print("❌ JSONLoader Failed \(error) from bundle")
            return nil
        }
    }
}

//
//  AchaNetwork.swift
//  Acha
//
//  Created by hong on 2022/11/24.
//

import Foundation

struct FBProvider {
    public func get<T: Decodable>(_ type: FBProviderType, responseType: T.Type) {
        let task = URLSession.shared.dataTask(with: type.toURLRequest()) { data, _, error in

            guard error == nil else {
                return }
            do {
                let data = try JSONDecoder().decode(responseType, from: data!)
            } catch {
                print(error)
            }
        }
        task.resume()
    }
}

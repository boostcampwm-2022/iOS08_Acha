//
//  AchaNetwork.swift
//  Acha
//
//  Created by hong on 2022/11/24.
//

import Foundation

struct FBProvider {
    public func get<T: Decodable>(_ type: ProvidableType, responseType: T.Type) {
        let task = URLSession.shared.dataTask(with: type.toURLRequest()!) { data, _, error in

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
    
    public func make(_ type: ProvidableType) {
        let task = URLSession.shared.dataTask(with: type.toURLRequest()!) { data, _, error in

            guard error == nil else {
                return }
            do {
                print(String(data: data!, encoding: .utf8))
            } catch {
                print(error)
            }
        }
        task.resume()
    }
}

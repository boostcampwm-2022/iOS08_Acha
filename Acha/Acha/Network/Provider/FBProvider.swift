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
                return
            }
            do {
                let data = try JSONDecoder().decode(responseType, from: data!)
                print(data)
            } catch {
                print("데이터 오류")
                print(error)
            }
        }
        task.resume()
    }
    
    public func make<T: Decodable>(_ type: ProvidableType, responseType: T.Type) {
        guard let urlRequest = type.toURLRequest() else {
            print("url Request 에러")
            return
        }
        let task = URLSession.shared.dataTask(with: urlRequest) { data, _, error in
            guard error == nil else {
                print(error)
                return
            }
            do {
                let data = try JSONDecoder().decode(responseType, from: data!)
                print(data)
            } catch {
                print(error)
            }
        }
        task.resume()
    }
}

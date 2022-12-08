//
//  DefaultFirebaseStorageNetworkService.swift
//  Acha
//
//  Created by 배남석 on 2022/12/07.
//

import RxSwift
import FirebaseStorage
import Foundation

final class DefaultFirebaseStorageNetworkService: FirebaseStorageNetworkService {
    private let storage = Storage.storage()
    
    enum FirebaseStorageError: Error {
        case dataError
        case decodeError
        case encodeError
    }
    
    func upload(type: FirebaseStorageType, data: Data) -> Single<URL> {
        return Single.create { [weak self] single in
            guard let self else { return Disposables.create() }
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            
            let firebaseReference = self.storage.reference().child(type.path)
            firebaseReference.putData(data, metadata: metaData) { metaData, error in
                firebaseReference.downloadURL { url, _ in
                    if let url {
                        single(.success(url))
                    } else {
                        single(.failure(error!))
                    }
                }
            }
            
            return Disposables.create()
        }
    }
    
    func upload(type: FirebaseStorageType, data: Data, completion: @escaping (URL?) -> Void) {
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        let firebaseReference = Storage.storage().reference().child(type.path)
        firebaseReference.putData(data, metadata: metaData) { _ , _ in
            firebaseReference.downloadURL { url, _ in
                completion(url)
            }
        }
    }
    
    func download(urlString: String, completion: @escaping (Data?) -> Void) {
        guard let url = URL(string: urlString) else { return }
    
        URLSession.shared.dataTask(with: url) { (data, response, _) in
            guard let data = data,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                completion(nil)
                return
            }
            
            completion(data)
        }.resume()
    }
}

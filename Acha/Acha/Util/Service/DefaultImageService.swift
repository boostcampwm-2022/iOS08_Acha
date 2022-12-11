//
//  DefaultImageService.swift
//  Acha
//
//  Created by 조승기 on 2022/12/01.
//
import Foundation
import RxSwift

final class DefaultImageService {
    static let shared = DefaultImageService()
    private init() {}
    
    private let fileManager = FileManager.default
    private let cachePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
    
    enum ImageServiceError: Error {
        case urlError
        case dataError
        case dataLoadError
        case unknownError
    }
    
    func loadImage(url: String) -> Observable<Data> {
        guard var pathURL = cachePath,
              let imageURL = URL(string: url) else {
            return Observable.error(ImageServiceError.urlError)
        }
        pathURL.appendPathComponent(imageURL.lastPathComponent)

        if diskCheck(pathURL: pathURL) {
            return diskLoad(pathURL: pathURL)
        }
        
        return networkLoad(imageURL: imageURL)
            .do(onNext: { [weak self] data in
                guard let self else { return }
                self.diskSave(pathURL: pathURL, data: data)
            })
    }
    
    private func diskCheck(pathURL: URL) -> Bool {
        return fileManager.fileExists(atPath: pathURL.path)
    }
    
    private func diskLoad(pathURL: URL) -> Observable<Data> {
        Observable<Data>.create { observer in
            guard let data = try? Data(contentsOf: pathURL) else {
                observer.onError(ImageServiceError.dataError)
                return Disposables.create()
            }
            DispatchQueue.main.async {
                observer.onNext(data)
            }
            return Disposables.create()
        }
    }
    
    private func diskSave(pathURL: URL, data: Data) {
        fileManager.createFile(atPath: pathURL.path, contents: data)
    }
    
    private func networkLoad(imageURL: URL) -> Observable<Data> {
        Observable<Data>.create { observer in
            DispatchQueue.global().async {
                guard let data = try? Data(contentsOf: imageURL) else {
                    observer.onError(ImageServiceError.dataLoadError)
                    return
                }
                DispatchQueue.main.async {
                    observer.onNext(data)
                }
            }
            return Disposables.create()
        }
    }
}

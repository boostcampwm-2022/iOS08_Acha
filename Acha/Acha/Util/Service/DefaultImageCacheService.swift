//
//  DefaultImageCacheService.swift
//  Acha
//
//  Created by 조승기 on 2022/12/11.
//

import Foundation
import RxSwift

struct DefaultImageCacheService: ImageCacheService {
    private let diskCache = DiskCache()
    private let memoryCache = MemoryCache.shared
    
    enum ImageCacheError: Error {
        case urlError
        case dataError
        case dataLoadError
        case unknownError
    }
    
    /// 필요합니다
    func isExist(imageURL: String) -> Bool {
        guard let url = URL(string: imageURL) else { return false }
        return memoryCache.isExist(imageURL: url) || diskCache.isExist(imageURL: url)
    }
    
    func load(imageURL: String) -> Single<Data> {
        guard let url = URL(string: imageURL) else {
            return Single<Data>.error(ImageCacheError.urlError)
        }
        
        if memoryCache.isExist(imageURL: url) {
            return memoryCache.load(imageURL: url)
        }
        
        if diskCache.isExist(imageURL: url) {
            return diskCache.load(imageURL: url)
                .do(onSuccess: {
                    memoryCache.write(imageURL: url, data: $0)
                })
        }
        
        return Single<Data>.error(ImageCacheError.unknownError)
    }
    
    func write(imageURL: String, image: Data) {
        guard let url = URL(string: imageURL) else { return }
        memoryCache.write(imageURL: url, data: image)
        diskCache.write(imageURL: url, data: image)
    }
}

struct DiskCache {
    enum DiskCacheError: Error {
        case dataError
    }
    private let pathURL: URL
    private let fileManager = FileManager.default
    var cacheSize: Int {
        directorySize(url: pathURL)
    }
    var maxCacheSize: Int {
        1024*1024*50
    }
    
    init() {
        let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        pathURL = directory.appendingPathComponent("ImageCache")
        if !fileManager.fileExists(atPath: pathURL.path) {
            try? fileManager.createDirectory(at: pathURL, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    func isExist(imageURL: URL) -> Bool {
        let path = pathURL.appendingPathComponent(imageURL.lastPathComponent)
        return fileManager.fileExists(atPath: path.path)
    }
    
    func load(imageURL: URL) -> Single<Data> {

        Single<Data>.create { single in
            let path = pathURL.appendingPathComponent(imageURL.lastPathComponent)
            DispatchQueue.global().async {
                guard let data = try? Data(contentsOf: path) else {
                    single(.failure(DiskCacheError.dataError))
                    return
                }
                DispatchQueue.main.async {
                    single(.success(data))
                }
            }
            try? fileManager.setAttributes([FileAttributeKey.modificationDate: Date()], ofItemAtPath: path.path)
            return Disposables.create()
        }
    }
    
    func write(imageURL: URL, data: Data?) {
        let path = pathURL.appendingPathComponent(imageURL.lastPathComponent)
        guard let data else { return }
        
        if cacheSize + data.count > maxCacheSize {
            removeCache(needSize: data.count)
        }
        
        // contentModificationDateKey을 현재로 설정하면서, 파일을 생성
        let attributes: [FileAttributeKey: Any] = [.modificationDate: Date()]
        fileManager.createFile(atPath: path.path, contents: data, attributes: attributes)
    }
    
    /// contentModificationDateKey 기준으로, 필요한 만큼만 삭제
    private func removeCache(needSize: Int) {
        let propertyKeys: [URLResourceKey] = [.fileSizeKey, .contentModificationDateKey]
        guard let resourceKeys = try? fileManager.contentsOfDirectory(at: pathURL,
                                                                      includingPropertiesForKeys: propertyKeys)
        else {
            return
        }
        
        let sortedResourceKeys = resourceKeys.sorted { url1, url2 in
            guard let date1 = try? url1.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate,
                  let date2 = try? url2.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate
            else {
                return false
            }
            return date1 < date2
        }
        
        var removedSize = 0
        for url in sortedResourceKeys {
            guard let fileSize = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize else {
                continue
            }
            
            try? fileManager.removeItem(at: url)
            removedSize += fileSize
            
            if removedSize >= needSize {
                break
            }
        }
    }
    
    /// fileSizeKey 를 이용해서, 디렉토리 내 파일들의 총 크기를 구함
    private func directorySize(url: URL) -> Int {
        guard let resourceKeys = try? fileManager.contentsOfDirectory(at: url,
                                                                      includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        return resourceKeys.reduce(0) { result, url in
            guard let fileSize = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize else {
                return result
            }
            return result + fileSize
        }
    }
}

struct MemoryCache {
    let cache = NSCache<AnyObject, AnyObject>()
    static let shared = MemoryCache(capacity: 1024*1024*50)
    
    init(capacity: Int) {
        cache.totalCostLimit = capacity
    }
    
    func isExist(imageURL: URL) -> Bool {
        cache.object(forKey: imageURL.lastPathComponent as AnyObject) != nil
    }
    
    func load(imageURL: URL) -> Single<Data> {
        Single<Data>.create { single in
            DispatchQueue.main.async {
                let data = cache.object(forKey: imageURL.lastPathComponent as AnyObject) as? Data
                single(.success(data ?? Data()))
            }
            return Disposables.create()
        }
    }
    
    func write(imageURL: URL, data: Data?) {
        cache.setObject(data as AnyObject, forKey: imageURL.lastPathComponent as AnyObject)
    }
}

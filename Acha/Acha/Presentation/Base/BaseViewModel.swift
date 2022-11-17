//
//  BaseViewModel.swift
//  Acha
//
//  Created by 조승기 on 2022/11/16.
//

import Foundation
import RxSwift

protocol BaseViewModel {
    associatedtype Input
    associatedtype Output
    
    var disposeBag: DisposeBag { get }
    
    func transform(input: Input) -> Output
}

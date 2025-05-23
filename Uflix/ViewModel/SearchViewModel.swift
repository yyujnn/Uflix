//
//  SearchViewModel.swift
//  Uflix
//
//  Created by 정유진 on 5/23/25.
//

import Foundation
import RxSwift
import RxCocoa

class SearchViewModel {
    // Input
    let query = PublishRelay<String>()
    
    // Output
    let results = BehaviorRelay<[Movie]>(value: [])
//    let recentSearches
    
    private let disposeBag = DisposeBag()
    
    init() {
       
    }
}

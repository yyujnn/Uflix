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
    // PublishRelay --> 초기값 x, 이벤트 발생(버튼/탭 등)
    let clearAllTapped = PublishRelay<Void>()
    let selectedKeyword = PublishRelay<String>()
    
    // Output
    // BehaviorRelay --> 초기값, 최신값 o, 즉시 전달 (상태 보관)
    var recentSearches = BehaviorRelay<[String]>(value: SearchHistoryManager.load())
    
    private let disposeBag = DisposeBag()
    
    init() {
        bindInput()
    }

    private func bindInput() {
        // 전체 삭제
        clearAllTapped
            .subscribe(onNext: {
                SearchHistoryManager.clear()
                self.recentSearches.accept([])
            }).disposed(by: disposeBag)
    
        // 최근 검색어 선택: 히스토리 갱신
        selectedKeyword
            .subscribe(onNext: { keyword in
                SearchHistoryManager.save(keyword)
                self.recentSearches.accept(SearchHistoryManager.load())
            }).disposed(by: disposeBag)
    }
}

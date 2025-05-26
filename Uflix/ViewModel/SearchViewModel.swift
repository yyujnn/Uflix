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
    let query = PublishRelay<String>()
    
    // Output
    // BehaviorRelay --> 초기값, 최신값 o, 즉시 전달 (상태 보관)
    var recentSearches = BehaviorRelay<[String]>(value: SearchHistoryManager.load())
    
    let results = BehaviorRelay<[Movie]>(value: [])
    let error = PublishRelay<Error>()
    
    private let disposeBag = DisposeBag()
    
    init() {
        // qeury 바인딩
        bindInput()
      
        // 더미 초기화
        recentSearches = BehaviorRelay<[String]>(value: [
            "범죄도시4",
            "인터스텔라",
            "해리포터",
            "어벤져스",
            "라라랜드"
        ])
    }
    
    func searchMovie(query: String) {
        // API 호출 로직
    }
    
    private func bindInput() {
        // 전체 삭제
        clearAllTapped
            .subscribe(onNext: {
                // 이벤트가 들어왔을 때 실행할 코드
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

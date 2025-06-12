//
//  MyNetflixViewModel.swift
//  Uflix
//
//  Created by 정유진 on 5/20/25.
//

import Foundation
import RxSwift
import RxCocoa

class MyNetflixViewModel {
    
    struct Input {
        let viewWillAppearTrigger: Observable<Void>
        let editButtonTapped: Observable<Void>
        let doneButtonTapped: Observable<Void>
        let deleteButtonTapped: Observable<Void>
        let itemSelected: Observable<IndexPath>
        let itemDeselected: Observable<IndexPath>
    }
    
    struct Output {
        let movies: Driver<[FavoriteMovie]>
        let isEditing: Driver<Bool>
        let selectedIDs: Driver<Set<Int>>
        let selectedMovie: Signal<FavoriteMovie>
    }

    // MARK: - State
    private let allMoviesRelay = BehaviorRelay<[FavoriteMovie]>(value: [])
    private let isEditingRelay = BehaviorRelay<Bool>(value: false)
    private let selectedIDsRelay = BehaviorRelay<Set<Int>>(value: [])
    private let selectedMovieRelay = PublishRelay<FavoriteMovie>()


    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        // 화면 진입 시 찜 목록 로딩
        input.viewWillAppearTrigger
            .subscribe(onNext: { [weak self] in
                self?.fetchFavorites()
            })
            .disposed(by: disposeBag)

        // 편집 버튼 → 편집모드 ON
        input.editButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.isEditingRelay.accept(true)
            })
            .disposed(by: disposeBag)

        // 완료 버튼 → 편집모드 OFF + 선택 초기화
        input.doneButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.isEditingRelay.accept(false)
                self?.selectedIDsRelay.accept([])
            })
            .disposed(by: disposeBag)

        // 삭제 버튼 → 선택된 항목 삭제
        input.deleteButtonTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                let selected = self.selectedIDsRelay.value
                let remaining = self.allMoviesRelay.value.filter { !selected.contains(Int($0.id)) }
                selected.forEach { CoreDataManager.shared.deleteFavorite(id: $0) }
                self.allMoviesRelay.accept(remaining)
                self.selectedIDsRelay.accept([])
            })
            .disposed(by: disposeBag)

        // 셀 선택
        input.itemSelected
            .withLatestFrom(Observable.combineLatest(allMoviesRelay, isEditingRelay)) { indexPath, pair in
                let (movies, isEditing) = pair
                return (movie: movies[indexPath.item], isEditing: isEditing)
            }
            .subscribe(onNext: { [weak self] result in
                guard let self else { return }
                
                if result.isEditing {
                    // 편집 모드일 때는 선택 상태만 갱신
                    var selected = self.selectedIDsRelay.value
                    selected.insert(Int(result.movie.id))
                    self.selectedIDsRelay.accept(selected)
                } else {
                    // 편집 모드 아닐 때는 상세 화면 전환
                    self.selectedMovieRelay.accept(result.movie)
                }
            })
            .disposed(by: disposeBag)

        // 셀 선택 해제
        input.itemDeselected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self else { return }
                let movie = self.allMoviesRelay.value[indexPath.item]
                var selected = self.selectedIDsRelay.value
                selected.remove(Int(movie.id))
                self.selectedIDsRelay.accept(selected)
            })
            .disposed(by: disposeBag)

        return Output(
            movies: allMoviesRelay.asDriver(),
            isEditing: isEditingRelay.asDriver(),
            selectedIDs: selectedIDsRelay.asDriver(),
            selectedMovie: selectedMovieRelay.asSignal()
        )
    }

    private func fetchFavorites() {
        let favorites = CoreDataManager.shared.fetchFavorites()
        allMoviesRelay.accept(favorites)
    }
}

//
//  MyNetflixViewController.swift
//  Uflix
//
//  Created by 정유진 on 5/20/25.
//

import UIKit
import RxSwift
import RxCocoa

class MyNetflixViewController: BaseViewController {
    
    private let viewModel: MyNetflixViewModel
    private let disposeBag = DisposeBag()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "찜한 시리즈"
        label.font = .boldSystemFont(ofSize: 22)
        label.textColor = UIColor.AppColor.textPrimary
        return label
    }()
    
    private let editButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)
    private let doneButton = UIButton(type: .system)
    
    private lazy var editStackView: UIStackView = {
       let stack = UIStackView(arrangedSubviews: [deleteButton, doneButton])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.isHidden = true
        return stack
    }()
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        cv.register(FavoriteMovieCell.self, forCellWithReuseIdentifier: FavoriteMovieCell.identifier)
        cv.backgroundColor = UIColor.AppColor.background
        return cv
    }()

    
    init(viewModel: MyNetflixViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }

    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / 3),
            heightDimension: .fractionalWidth(1.0 / 3 * 1.8)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: itemSize.heightDimension
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        group.interItemSpacing = .fixed(10)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = .init(top: 10, leading: 10, bottom: 20, trailing: 10)

        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.AppColor.background
        
        [ titleLabel, editButton, editStackView, collectionView].forEach {
            view.addSubview($0)
        }
     
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalToSuperview().inset(16)
        }
        
        editButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.trailing.equalToSuperview().inset(16)
        }
        
        editStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.trailing.equalToSuperview().inset(16)
        }
        
        collectionView.backgroundColor = UIColor.AppColor.background
        collectionView.register(FavoriteMovieCell.self, forCellWithReuseIdentifier: FavoriteMovieCell.identifier)
        collectionView.allowsMultipleSelection = true
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(editButton.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        editButton.setTitle("편집", for: .normal)
        editButton.setTitleColor(.white, for: .normal)
        editButton.isHidden = false

        deleteButton.setTitle("삭제", for: .normal)
        deleteButton.setTitleColor(.systemRed, for: .normal)

        doneButton.setTitle("완료", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)

        editStackView.isHidden = true // ← 안전하게 다시 한 번 초기화
    }
    
    private func bind() {
        let input = MyNetflixViewModel.Input(
            viewWillAppearTrigger: rx.methodInvoked(#selector(viewWillAppear(_:))).map { _ in },
            editButtonTapped: editButton.rx.tap.asObservable(),
            doneButtonTapped: doneButton.rx.tap.asObservable(),
            deleteButtonTapped: deleteButton.rx.tap.asObservable(),
            itemSelected: collectionView.rx.itemSelected.asObservable(),
            itemDeselected: collectionView.rx.itemDeselected.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        // 1. 영화 목록 바인딩
        output.movies
            .drive(collectionView.rx.items(
                cellIdentifier: FavoriteMovieCell.identifier,
                cellType: FavoriteMovieCell.self
            )) { index, movie, cell in
                cell.configure(movie: movie, isEditing: false, isSelected: false)
            }
            .disposed(by: disposeBag)
        
        // 2. 편집 모드 상태 → 버튼 UI 전환 및 reloadData
        output.isEditing
            .drive(onNext: { [weak self] isEditing in
                guard let self = self else { return }
                self.editButton.isHidden = isEditing
                self.editStackView.isHidden = !isEditing
                self.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        // 3. 선택된 셀만 reload → check 표시 반영
        Observable
            .combineLatest(output.movies.asObservable(), output.selectedIDs.asObservable(), output.isEditing.asObservable())
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] movies, selectedIDs, isEditing in
                guard let self = self else { return }
                
                for (index, movie) in movies.enumerated() {
                    let indexPath = IndexPath(item: index, section: 0)
                    guard let cell = self.collectionView.cellForItem(at: indexPath) as? FavoriteMovieCell else { continue }
                    
                    let isSelected = selectedIDs.contains(Int(movie.id))
                    cell.configure(movie: movie, isEditing: isEditing, isSelected: isSelected)
                    
                    if isSelected {
                        print("✅ 선택된 셀: \(movie.title ?? "제목 없음") (id: \(movie.id))")
                    }
                    let selectedMovies = movies.filter { selectedIDs.contains(Int($0.id)) }
                    print("❗️ 선택된 셀 전체 (\(selectedMovies.count)개):")
                    selectedMovies.forEach { movie in
                        print("• \(movie.title ?? "제목 없음")")
                    }
                }
            })
            .disposed(by: disposeBag)
       
        output.showDeleteAlert
            .emit(onNext: { [weak self] in
                self?.showDeleteConfirmationAlert()
            })
            .disposed(by: disposeBag)

        output.selectedMovie
            .emit(onNext: { [weak self] movie in
                self?.navigateToDetail(for: movie)
            })
            .disposed(by: disposeBag)
        
    }
    
    private func showDeleteConfirmationAlert() {
        let alert = UIAlertController(
            title: "정말 삭제하시겠어요?",
            message: "선택한 영화들이 삭제됩니다.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { [weak self] _ in
            self?.viewModel.performDeletion()
        }))

        present(alert, animated: true, completion: nil)
    }

    
    private func navigateToDetail(for movie: FavoriteMovie) {
        let model = Movie(
            id: Int(movie.id),
            title: movie.title ?? "",
            posterPath: movie.posterPath,
            overview: movie.overview ?? ""
        )
        let detailVM = DetailViewModel(movie: model)
        let detailVC = DetailViewController(viewModel: detailVM)
        detailVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}

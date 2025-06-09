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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchFavorites()
    }

    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / 3),
            heightDimension: .estimated(180)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(180)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: 3
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
            editButtonTapped: editButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        // 버튼 이벤트 처리
        editButton.rx.tap
            .bind(onNext: { [weak self] in
                self?.editButton.isHidden = true
                self?.editStackView.isHidden = false
                self?.viewModel.isEditingRelay.accept(true)
            }).disposed(by: disposeBag)
        
        doneButton.rx.tap
            .bind(onNext: { [weak self] in
                guard let self = self else { return }
                self.editStackView.isHidden = true
                self.editButton.isHidden = false
                self.viewModel.isEditingRelay.accept(false)
                self.viewModel.selectedIDsRelay.accept([])
                
                // 셀 선택 해제
                for indexPath in self.collectionView.indexPathsForSelectedItems ?? [] {
                    self.collectionView.deselectItem(at: indexPath, animated: false)
                }
            })
            .disposed(by: disposeBag)
        
        // todo: 삭제 alert
        deleteButton.rx.tap
            .withLatestFrom(viewModel.selectedIDsRelay.asObservable())
            .bind(onNext: { [weak self] selectedIDs in
                guard let self = self else { return }
                let moviesToDelete = self.viewModel.allMovies.value.filter {
                    selectedIDs.contains(Int($0.id))
                }
                moviesToDelete.forEach {
                    self.viewModel.deleteFavorite($0)
                }
                self.viewModel.selectedIDsRelay.accept([])
            })
            .disposed(by: disposeBag)
        
        output.isEditing
            .drive(onNext: { [weak self] _ in
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        output.movies
            .drive(collectionView.rx.items(
                cellIdentifier: FavoriteMovieCell.identifier,
                cellType: FavoriteMovieCell.self
            )) { [weak self] index, movie, cell in
                cell.configure(movie: movie)
                cell.isEditing = self?.viewModel.isEditingRelay.value ?? false
            }.disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                
                let movie = self.viewModel.allMovies.value[indexPath.item]
                
                if self.viewModel.isEditingRelay.value {
                    var selected = self.viewModel.selectedIDsRelay.value
                    selected.insert(Int(movie.id))
                    self.viewModel.selectedIDsRelay.accept(selected)
                    
                    print("✅ 선택된 셀: \(movie.title ?? "제목 없음") (id: \(movie.id))")
                    print("📌 현재 selectedIDsRelay: \(selected)")
                } else {
                    self.navigateToDetail(for: movie)
                    self.collectionView.deselectItem(at: indexPath, animated: false)
                }
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.itemDeselected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                let movie = self.viewModel.allMovies.value[indexPath.item]
                let id = Int(movie.id)
                var selected = self.viewModel.selectedIDsRelay.value
                selected.remove(id)
                self.viewModel.selectedIDsRelay.accept(selected)
            })
            .disposed(by: disposeBag)
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
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}

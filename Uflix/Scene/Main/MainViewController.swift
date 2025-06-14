//
//  ViewController.swift
//  Uflix
//
//  Created by 정유진 on 3/18/25.
//

import UIKit
import SnapKit
import RxSwift
import AVKit
import AVFoundation

class MainViewController : BaseViewController {
    
    private let viewModel = MainViewModel()
    private let disposeBag = DisposeBag()
    private var popularMovies = [Movie]()
    private var topRatedMovies = [Movie]()
    private var upcomingMovies = [Movie]()
    
    private let logoLabel: UILabel = {
        let label = UILabel()
        label.text = "NETFLIX"
        label.textColor = UIColor.AppColor.accentRed
        label.font = UIFont(name: "HelveticaNeue-CondensedBlack", size: 32) ?? UIFont.boldSystemFont(ofSize: 32)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        cv.register(PosterCell.self, forCellWithReuseIdentifier: PosterCell.id)
        cv.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.id)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = UIColor.AppColor.background
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setupUI()
    }

    private func bind() {
        let input = MainViewModel.Input(fetchTrigger: Observable.just(()))
    
        let output = viewModel.transform(input: input)
        
        Observable
            .combineLatest(
                output.popularMovies, 
                output.topRatedMovies, 
                output.upcomingMovies)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] popular, topRated, upcoming in
                self?.popularMovies = popular
                self?.topRatedMovies = topRated
                self?.upcomingMovies = upcoming
                self?.collectionView.reloadData() // 단 1번만 호출
            }, onError: { error in
                print("에러 발생: \(error)")
            }).disposed(by: disposeBag)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // 각 그룹 넓이는 화면 넓이의 25% 차지하고, 높이는 넓이의 40%
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.25),
            heightDimension: .fractionalWidth(0.4)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 10
        section.contentInsets = .init(top: 10, leading: 10, bottom: 20, trailing: 10)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.AppColor.background
        [
            logoLabel,
            collectionView
        ].forEach { view.addSubview($0) }
        
        logoLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(10)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(logoLabel.snp.bottom).offset(20)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide.snp.horizontalEdges)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    private func playVideoUrl() {
        // url 을 인자로 받지만, 유튜브 url 은 정책상 바로 재생할 수 없으므로
        // 임의로 url 넣어서 동영상 재생 구현 연습
        let url = URL(string: "https://storage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4")!
        
        let player = AVPlayer(url: url)
        
        let playerViewController = AVPlayerViewController()
        
        playerViewController.player = player
        
        present(playerViewController, animated: true) {
            player.play()
        }
    }
}

enum Section: Int, CaseIterable {
    case popularMovies
    case topRatedMovies
    case upcomingMovies
    
    var title: String {
        switch self {
        case .popularMovies: return "이 시간 핫한 영화"
        case .topRatedMovies: return "가장 평점이 높은 영화"
        case .upcomingMovies: return "곧 개봉되는 영화"
        }
    }
}

extension MainViewController: UICollectionViewDelegate {
    // collectionView 클릭
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMovie: Movie
        
        switch Section(rawValue: indexPath.section) {
        case .popularMovies:
            selectedMovie = popularMovies[indexPath.row]
        case .topRatedMovies:
            selectedMovie = topRatedMovies[indexPath.row]
        case .upcomingMovies:
            selectedMovie = upcomingMovies[indexPath.row]
        default:
            return
        }
        
        let detailViewModel = DetailViewModel(movie: selectedMovie)
        let detailVC = DetailViewController(viewModel: detailViewModel)
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension MainViewController: UICollectionViewDataSource {
    
    // indexPath 별로 cell 을 구현
    // tableView 의 cellForRowAt 과 비슷한 역할
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PosterCell.id, for: indexPath) as? PosterCell else { return UICollectionViewCell() }
        
        switch Section(rawValue: indexPath.section) {
        case .popularMovies:
            cell.configure(with: popularMovies[indexPath.row])
        case .topRatedMovies:
            cell.configure(with: topRatedMovies[indexPath.row])
        case .upcomingMovies:
            cell.configure(with: upcomingMovies[indexPath.row])
        default:
            return UICollectionViewCell()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SectionHeaderView.id,
            for: indexPath
        ) as? SectionHeaderView else { return UICollectionReusableView() }
        
        let sectionType = Section.allCases[indexPath.section]
        headerView.configure(with: sectionType.title)
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .popularMovies: return popularMovies.count
        case .topRatedMovies: return topRatedMovies.count
        case .upcomingMovies: return upcomingMovies.count
        default: return 0
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }
}


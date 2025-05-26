//
//  SearchResultView.swift
//  Uflix
//
//  Created by 정유진 on 5/26/25.
//

import UIKit
import SnapKit

final class SearchResultView: UIView {

    // 외부에서 접근 가능한 collectionView
    let collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { _, _ in
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

            return section
        }

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .black
        cv.register(PosterCell.self, forCellWithReuseIdentifier: PosterCell.id)
        return cv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(collectionView)

        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

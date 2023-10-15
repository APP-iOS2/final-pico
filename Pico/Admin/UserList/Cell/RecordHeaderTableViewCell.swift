//
//  RecordHeaderTableViewCell.swift
//  Pico
//
//  Created by 최하늘 on 10/13/23.
//

import UIKit
import SnapKit
import RxSwift

enum RecordType: CaseIterable {
    case report
    case block
    case like
    
    var name: String {
        switch self {
        case .report:
            return "신고 기록"
        case .block:
            return "차단 기록"
        case .like:
            return "좋아요 기록"
        }
    }
}

final class RecordHeaderTableViewCell: UITableViewCell {
        
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        view.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 20)
        return view
    }()
    
    private var selectedCellIndex: Int = 0
    
    let selectedRecordTypePublisher = BehaviorSubject(value: RecordType.report)
    
    // MARK: - initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addViews()
        makeConstraints()
        configCollectionView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cell: RecordHeaderCollectionViewCell.self)
    }
}

// MARK: - 컬렉션뷰 관련
extension RecordHeaderTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return RecordType.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath, cellType: RecordHeaderCollectionViewCell.self)
        guard let recordType = RecordType.allCases[safe: indexPath.row] else { return UICollectionViewCell() }
        cell.isSelectedCell = indexPath.row == selectedCellIndex
        cell.config(text: recordType.name)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        let recordType = RecordType.allCases[safe: indexPath.row]
        label.text = recordType?.name
        label.sizeToFit()
        let labelWidth = label.frame.size.width
        let labelHeight = label.frame.size.height
        
        return CGSize(width: labelWidth + 30, height: labelHeight + 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCellIndex = indexPath.row
        collectionView.reloadData()
        
        guard let recordType = RecordType.allCases[safe: selectedCellIndex] else { return }
        selectedRecordTypePublisher.onNext(recordType)
    }
}

// MARK: - UI 관련
extension RecordHeaderTableViewCell {
    func addViews() {
        contentView.addSubview(collectionView)
    }
    
    func makeConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

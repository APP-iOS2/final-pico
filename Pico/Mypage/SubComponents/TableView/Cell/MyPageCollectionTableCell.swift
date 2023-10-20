//
//  MyPageCollectionTableCell.swift
//  Pico
//
//  Created by 김민기 on 2023/09/26.
//

import UIKit
import SnapKit
import RxSwift

protocol MyPageCollectionDelegate: AnyObject {
    func didSelectItem(item: Int)
}

final class MyPageCollectionTableCell: UITableViewCell {
    weak var delegate: MyPageCollectionDelegate?
    
    private let collectionViewFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 18
        layout.minimumInteritemSpacing = 0
        return layout
    }()
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewFlowLayout)
        view.isScrollEnabled = false
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.contentInset = .zero
        view.register(MyPageCollectionCell.self, forCellWithReuseIdentifier: "MyPageCollectionCell")
        return view
    }()
    
    private var viewModel: ProfileViewModel?
    private let disposeBag = DisposeBag()
    private var chuCount: Int?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configCollectionView()
        addSubView()
        makeConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configViewModel(viewModel: ProfileViewModel) {
        viewModel.chuCount
            .observe(on: MainScheduler.instance)
            .subscribe {
                self.chuCount = $0
                self.collectionView.reloadData()
            }
            .disposed(by: disposeBag)
    }
    
    private func configCollectionView() {
        collectionView.backgroundColor = .picoLightGray
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func addSubView() {
        [collectionView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func makeConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}

extension MyPageCollectionTableCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyPageCollectionCell", for: indexPath) as? MyPageCollectionCell else { return UICollectionViewCell() }
        
        cell.backgroundColor = .white
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 10
        switch indexPath.row {
        case 0:
            cell.configure(imageName: "chu", title: "내 포인트", subTitle: "\(chuCount ?? 0) 츄")
        case 1:
            cell.configure(imageName: "tempImage", title: "MbTI검사", subTitle: "내 성향 알아보기")
        default:
            break
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.bounds.width / 2) - 10
        let cellHeight = collectionView.bounds.height
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectItem(item: indexPath.row)
    }
}

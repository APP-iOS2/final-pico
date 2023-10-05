//
//  LikeCollectionViewCell.swift
//  Pico
//
//  Created by 방유빈 on 2023/09/26.
//

import UIKit
import SnapKit
import RxSwift

final class LikeCollectionViewCell: UICollectionViewCell {
    private var disposeBag: DisposeBag = DisposeBag()
    private var viewModel: LikeMeViewViewModel?
    private var user: User?
    
    var buttonTapObservable: Observable<Void> {
        return deleteButton.rx.tap.asObservable()
    }
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(configuration: .plain())
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .light)
        let image = UIImage(systemName: "xmark.circle.fill", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .white.withAlphaComponent(0.8)
        return button
    }()
    
    private let messageButton: UIButton = {
        let button = UIButton(configuration: .plain())
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .light)
        let image = UIImage(systemName: "paperplane.circle", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        return button
    }()
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
        makeConstraints()
        configDeleteButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configData(images: [String], nameText: String, isHiddenDeleteButton: Bool, isHiddenMessageButton: Bool) {
        userImageView.loadImage(url: images[0], disposeBag: self.disposeBag)
        nameLabel.text = nameText
        messageButton.isHidden = isHiddenMessageButton
        deleteButton.isHidden = isHiddenDeleteButton
    }
   
// 질문: 이 코드를 추가하면 삭제버튼이 처음 한번만되고 그 다음부터는 먹히지않음
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        disposeBag = DisposeBag()
//    }
    
    private func configDeleteButton() {
        buttonTapObservable
            .subscribe(onNext: { [weak self] in
                if let user = self?.user {
                    self?.viewModel?.deleteButtonTapUser.onNext(user)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func configureLikeMeViewModel(user: User, viewModel: LikeMeViewViewModel) {
        self.user = user
        self.viewModel = viewModel
    }
    
    private func addViews() {
        [userImageView, nameLabel, deleteButton, messageButton].forEach { item in
            addSubview(item)
        }
    }
    
    private func makeConstraints() {
        userImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)

        }
        nameLabel.setContentHuggingPriority(.required, for: .vertical)
        nameLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        deleteButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().offset(5)
        }
        
        messageButton.snp.makeConstraints { make in
            make.top.equalTo(nameLabel)
            make.leading.equalTo(nameLabel.snp.trailing).offset(5)
            make.trailing.bottom.equalToSuperview().offset(-5)
            make.width.equalTo(messageButton.snp.height)
        }
    }
}

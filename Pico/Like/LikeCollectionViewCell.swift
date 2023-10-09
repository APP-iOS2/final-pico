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
    
    var deleteButtonTapObservable: Observable<Void> {
        return deleteButton.rx.tap.asObservable()
    }
    
    var messageButtonTapObservable: Observable<Void> {
        return messageButton.rx.tap.asObservable()
    }
    
    private var disposeBag: DisposeBag = DisposeBag()
    private var likeMeViewModel: LikeMeViewModel?
    private var likeUViewModel: LikeUViewModel?
    private var user: User?
    
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
    
    private let mbtiLabel: MBTILabelView = MBTILabelView(mbti: .enfj, scale: .small)
    
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
    
    private let likeButton: UIButton = {
        let button = UIButton(configuration: .plain())
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .light)
        let image = UIImage(systemName: "heart.circle", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        return button
    }()
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
        makeConstraints()
        configDeleteButton()
        configMessageButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        userImageView.image = UIImage(named: "chu")
        nameLabel.text = ""
    }
    
    func configData(image: String, nameText: String, isHiddenDeleteButton: Bool, isHiddenMessageButton: Bool, mbti: MBTIType) {
        userImageView.loadImage(url: image, disposeBag: self.disposeBag)
        nameLabel.text = nameText
        mbtiLabel.setMbti(mbti: mbti)
        messageButton.isHidden = isHiddenMessageButton
        deleteButton.isHidden = isHiddenDeleteButton
        likeButton.isHidden = isHiddenDeleteButton
    }
   
// 질문: 이 코드를 추가하면 삭제버튼이 처음 한번만되고 그 다음부터는 먹히지않음
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        disposeBag = DisposeBag()
//    }
    
    private func configDeleteButton() {
        deleteButtonTapObservable
            .subscribe(onNext: { [weak self] in
                if let user = self?.user {
                    self?.likeMeViewModel?.deleteButtonTapUser.onNext(user)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func configMessageButton() {
        messageButtonTapObservable
            .subscribe(onNext: { [weak self] in
                if let user = self?.user {
                    self?.likeUViewModel?.messageButtonTapUser.onNext(user)
                }
            })
            .disposed(by: disposeBag)
    }
    
    /*
     질문 : deleteButtonTapObservable 처럼 셀 버튼의 옵저버블을 셀 안에서 만들고 구독해서 버튼을 클릭하면
        뷰모델의 서브젝트에 User정보를 전달해 뷰모델에서 처리 함수를 실행시키도록 만들었는데
        이때 뷰컨트롤러에서 가지고 있던 뷰모델과 선택된 유저정보를 셀로 전달해주는 것이 맞나요?
        전달을 하는게 아니라면 선택된 셀에 대해 독립적으로 이벤트가 실행되도록할라면 어떤 방법이 있을지
     */
    func configLikeMeViewModel(userId: String, viewModel: LikeMeViewModel) {
        FirestoreService.shared.loadDocument(collectionId: .users, documentId: userId, dataType: User.self) { result in
            switch result {
            case .success(let data):
                self.likeMeViewModel = viewModel
                self.user = data
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func configLikeUViewModel(userId: String, viewModel: LikeUViewModel) {
        FirestoreService.shared.loadDocument(collectionId: .users, documentId: userId, dataType: User.self) { result in
            switch result {
            case .success(let data):
                self.likeUViewModel = viewModel
                self.user = data
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func addViews() {
        [userImageView, nameLabel, mbtiLabel, deleteButton, messageButton, likeButton].forEach { item in
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
        
        mbtiLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.bottom.equalTo(nameLabel.snp.top).offset(-5)
            make.width.equalTo(mbtiLabel.frame.size.width)
            make.height.equalTo(mbtiLabel.frame.size.height)
        }
        
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
        
        likeButton.snp.makeConstraints { make in
            make.top.equalTo(nameLabel)
            make.leading.equalTo(nameLabel.snp.trailing).offset(5)
            make.trailing.bottom.equalToSuperview().offset(-5)
            make.width.equalTo(messageButton.snp.height)
        }
    }
}

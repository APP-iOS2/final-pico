//
//  MypageViewController.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit
import SnapKit

final class MypageViewController: UIViewController {

    private let profilView = ProfilView()
    private let myPageTableView = MyPageTableView()
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 10
        return view
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "김민기,"
        label.font = UIFont.picoTitleFont
        return label
    }()
    
    private let userAgeLabel: UILabel = {
        let label = UILabel()
        label.text = "100"
        label.font = UIFont.picoTitleFont
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configBarItem()
        configTapGesture()
        addViews()
        makeConstraints()
        myPageTableView.myPageDelegate = self
    }
    
    private func configBarItem() {
        let setButton = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .done, target: self, action: #selector(tappedBarButton))
        setButton.tintColor = .darkGray
        navigationItem.rightBarButtonItem = setButton
    }
    
    private func configTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedProfileView))
        profilView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func tappedProfileView() {
        let viewController = ProfileEditViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func tappedBarButton(_ sender: UIBarButtonItem) {
        let viewController = SettingViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func addViews() {
        [profilView, stackView, myPageTableView].forEach {
            view.addSubview($0)
        }
        [userNameLabel, userAgeLabel].forEach {
            stackView.addArrangedSubview($0)
        }
    }
    
    private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        profilView.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(170)
            make.height.equalTo(170)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(profilView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        myPageTableView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

extension MypageViewController: MyPageDelegate {
    func didSelectItem(item: Int) {
        let viewController = StoreViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

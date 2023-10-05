//
//  AdminViewController.swift
//  Pico
//
//  Created by 최하늘 on 10/4/23.
//

import UIKit
import SnapKit

final class AdminViewController: BaseViewController {
    struct DummyUser {
        let name: String
        let age: Int
        let imageUrl: String
        let createdDate: String
        var title: String {
            return "\(name), \(age)"
        }
    }
    
    enum SortType: CaseIterable {
        case dateAscending
        case dateDescending
        case nameAscending
        case nameDescending
        case ageAscending
        case ageDescending
        
        var name: String {
            switch self {
            case .dateAscending:
                return "가입일 오름차순"
            case .dateDescending:
                return "가입일 내림차순"
            case .nameAscending:
                return "이름 오름차순"
            case .nameDescending:
                return "이름 내림차순"
            case .ageAscending:
                return "나이 오름차순"
            case .ageDescending:
                return "나이 내림차순"
            }
        }
    }
    
    enum FilterType: CaseIterable {
        case name
        case mbti
        
        var name: String {
            switch self {
            case .name:
                return "이름"
            case .mbti:
                return "MBTI"
            }
        }
    }
    
    private let users: [DummyUser] = [
        DummyUser(name: "찐 윈터", age: 21, imageUrl: "https://image5jvqbd.fmkorea.com/files/attach/new2/20211225/3655109/3113058505/4195166827/e130faca7194985e4f162b3583d52853.jpg", createdDate: "2022.09.12"),
        DummyUser(name: "찐 윈터라니깐여;", age: 21, imageUrl: "https://image5jvqbd.fmkorea.com/files/attach/new2/20211225/3655109/3113058505/4195166827/e130faca7194985e4f162b3583d52853.jpg", createdDate: "2021.01.24"),
        DummyUser(name: "풍리나", age: 35, imageUrl: "https://flexible.img.hani.co.kr/flexible/normal/640/441/imgdb/original/2023/0525/20230525501996.jpg", createdDate: "2012.07.04")
    ]
    
    private var selectedSortType: SortType = .dateAscending
    private var selectedFilteredType: FilterType = .name
    
    private var sortedUsers: [DummyUser] {
        switch selectedSortType {
        case .dateAscending:
            return users.sorted { $0.createdDate < $1.createdDate }
        case .dateDescending:
            return users.sorted { $0.createdDate > $1.createdDate }
        case .nameAscending:
            return users.sorted { $0.name < $1.name }
        case .nameDescending:
            return users.sorted { $0.name > $1.name }
        case .ageAscending:
            return users.sorted { $0.age < $1.age }
        case .ageDescending:
            return users.sorted { $0.age > $1.age }
        }
    }
    
    private var filteredUsers: [DummyUser] {
        switch selectedFilteredType {
        case .name:
            return users.filter { user in
                user.name.contains("")
            }
        case .mbti:
            return users
        }
    }
    
    private lazy var menu: UIMenu = {
        return UIMenu(title: "정렬", options: [.singleSelection], children: menuItems)
    }()
    
    private lazy var menuItems: [UIAction] = {
        return SortType.allCases.map { sortType in
            let title = sortType.name
            
            return UIAction(title: title, image: UIImage(), handler: { [weak self] _ in
                guard let self = self else { return }
                selectedSortType = sortType
                userListTableView.reloadData()
            })
        }
    }()
    
    private lazy var filteredButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("이름", for: .normal)
        button.menu = UIMenu(title: "정렬", options: [.singleSelection], children: menuItems)
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    private let textField = CommonTextField()
    private let userListTableView = UITableView()

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        makeConstraints()
        configNavigationBarItem()
        configTableView()
    }
    
    // MARK: - config
    private func configNavigationBarItem() {
        let filterButton = UIBarButtonItem(image: UIImage(systemName: "slider.horizontal.3"), menu: menu)
        filterButton.tintColor = .darkGray
        self.navigationItem.rightBarButtonItem = filterButton
    }
    
    private func configTableView() {
        userListTableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: Identifier.TableCell.notiTableCell)
        userListTableView.delegate = self
        userListTableView.dataSource = self
        if #available(iOS 15.0, *) {
            userListTableView.tableHeaderView = UIView()
        }
    }
}

// MARK: - 테이블뷰관련
extension AdminViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.TableCell.notiTableCell, for: indexPath) as? NotificationTableViewCell else {
            return UITableViewCell()
        }
        cell.configData(imageUrl: sortedUsers[indexPath.row].imageUrl, title: sortedUsers[indexPath.row].title, createdDate: sortedUsers[indexPath.row].createdDate)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("zmfflr \(indexPath.row)")
    }
}

// MARK: - UI 관련
extension AdminViewController {
    
    private func addViews() {
        view.addSubview(filteredButton)
        view.addSubview(textField)
        view.addSubview(userListTableView)
    }
    
    private func makeConstraints() {
        let padding: CGFloat = 10
        
        filteredButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(padding)
            make.leading.equalTo(padding)
            make.width.equalTo(80)
            make.height.equalTo(40)
        }
        
        textField.snp.makeConstraints { make in
            make.top.equalTo(filteredButton)
            make.leading.equalTo(filteredButton.snp.trailing).offset(padding)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-padding)
            make.height.equalTo(filteredButton.snp.height)
        }
        
        userListTableView.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(padding)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

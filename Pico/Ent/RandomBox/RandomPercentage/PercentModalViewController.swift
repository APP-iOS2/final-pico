//
//  PercentModalViewController.swift
//  Pico
//
//  Created by 오영석 on 10/17/23.
//

import UIKit

final class PercentModalViewController: UIViewController {
    
    private let tableView = UITableView()
    
    private let percentInfo: [[String]] = [
        ["초급 박스", "50%", "35%", "15%", "5%"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        makeConstraints()
        configTableView()
    }
    
    private func addViews() {
        view.addSubview(tableView)
    }
    
    private func makeConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func configTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    private func configModalView() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(tappedCancelButton))
            navigationItem.leftBarButtonItem = cancelButton
    }
    
    @objc private func tappedCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension PercentModalViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return percentInfo.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return percentInfo[section].count - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = percentInfo[indexPath.section][indexPath.row + 1]
        cell.textLabel?.text = item
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return percentInfo[section][0]
    }
}

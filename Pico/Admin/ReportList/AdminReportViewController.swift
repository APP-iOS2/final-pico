//
//  AdminReportViewController.swift
//  Pico
//
//  Created by 최하늘 on 10/11/23.
//

import UIKit

final class AdminReportViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configAdminSubViewConroller()
        addViews()
        makeConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    private func addViews() {
        
    }
    
    private func makeConstraints() {
        
    }
}

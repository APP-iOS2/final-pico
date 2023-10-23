//
//  SettingNotiTableCell.swift
//  Pico
//
//  Created by 김민기 on 2023/09/26.
//

import UIKit
import SnapKit

final class SettingNotiTableCell: UITableViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .picoFontBlack
        label.font = UIFont.picoSubTitleFont
        label.text = "알림허용"
        return label
    }()
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .picoFontBlack
        label.font = UIFont.picoDescriptionFont
        label.text = "모든 알림을 허용합니다"
        return label
    }()
    private let switchButton: SwitchButton = {
        let button = SwitchButton(frame: CGRect(x: 0, y: 0, width: 25, height: 0))
        return button
    }()
    weak var switchButtonDelegate: SwitchButtonDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubView()
        makeConstraints()
        cofigButton()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func cofigButton() {
        switchButtonDelegate = self
        switchButton.switchButtonDelegate = switchButtonDelegate
    }
    
    func configure(titleLabel: String, subTitleLabel: String, state: Bool) {
        self.titleLabel.text = titleLabel
        self.subTitleLabel.text = subTitleLabel
        switchButton.congifState(bool: state)
    }
    
    private func addSubView() {
        [titleLabel, subTitleLabel, switchButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func makeConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-15)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
        subTitleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(15)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
        switchButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-15)
            make.width.equalTo(40)
        }
    }
}

extension SettingNotiTableCell: SwitchButtonDelegate {
    func isOnValueChange(isOnSwitch: Bool) {
        if isOnSwitch {
            
            let current = UNUserNotificationCenter.current()
            current.getNotificationSettings(completionHandler: { permission in
                switch permission.authorizationStatus {
                case .authorized:
                    debugPrint("User granted permission for notification")
                case .denied, .notDetermined, .ephemeral:
                    DispatchQueue.main.async {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let viewController = windowScene.windows.first?.rootViewController {
                        viewController.showCustomAlert(alertType: .canCancel, titleText: "위치 권한 필요", messageText: "이 앱을 사용하려면 위치 권한이 필요합니다. 설정에서 권한을 변경할 수 있습니다.", confirmButtonText: "설정으로 이동", comfrimAction: {
                            viewController.navigationController?.popViewController(animated: true)
                            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(settingsURL)
                            }
                        })
                    }
                    }
                case .provisional:
                    break
                @unknown default:
                  break
                }
            })
        } else {
           debugPrint("off")
        }
    }
}

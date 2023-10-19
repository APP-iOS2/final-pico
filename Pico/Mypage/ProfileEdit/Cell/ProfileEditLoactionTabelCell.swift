//
//  ProfileEditLoactionTabelCell.swift
//  Pico
//
//  Created by 김민기 on 2023/09/27.
//

import UIKit
import SnapKit

final class ProfileEditLoactionTabelCell: UITableViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .picoFontBlack
        label.font = UIFont.picoSubTitleFont
        label.text = "내 위치"
        return label
    }()
    
    private lazy var locationChangeButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "chu")?.resized(toSize: CGSize(width: 30, height: 30))
        var configuration = UIButton.Configuration.plain()
        configuration.subtitle = "경기도 용인시"
        configuration.subtitleLineBreakMode = .byTruncatingTail
        configuration.image = image
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 3
        button.configuration = configuration
        button.addTarget(self, action: #selector(tappedButton), for: .touchUpInside)
        return button
    }()
    
    private var profileEditViewModel: ProfileEditViewModel?
    private let locationManager = LocationManager()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubView()
        makeConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(location: String, viewModel: ProfileEditViewModel) {
        locationChangeButton.configuration?.subtitle = location
        profileEditViewModel = viewModel
    }

    private func locationConfigure() {
        locationManager.configLocation()
    }
    
    @objc private func tappedButton() {
        locationConfigure()
        profileEditViewModel?.modalType = .location
        let space = locationManager.locationManager.location?.coordinate
        let lat = space?.latitude
        let long = space?.longitude

        locationManager.getAddress(latitude: lat, longitude: long) { [weak self] location in
            guard let self else { return }
            if let location = location {
                profileEditViewModel?.updateData(data: location)
            } else {
                self.locationManager.configLocation()
            }
        }
    }
    
    private func addSubView() {
        [titleLabel, locationChangeButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func makeConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(locationChangeButton.snp.leading).offset(-120)
        }
        
        locationChangeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
    }
}

//
//  WorldCupUserInfoStackView.swift
//  Pico
//
//  Created by 오영석 on 2023/09/26.
//
import UIKit
import SnapKit

final class WorldCupUserInfoStackView: UIView {

    private let labelTexts = ["키", "직업", "지역"]
    private let labelTexts2 = ["157", "대학생", "서울시 노원구"]

    private lazy var labels: [UILabel] = labelTexts.map { text in
        let label = UILabel()
        label.text = text
        label.textAlignment = .left
        label.textColor = UIColor.picoFontGray.withAlphaComponent(0.5)
        label.font = UIFont.picoDescriptionFont

        return label
    }

    private lazy var dataLabels: [UILabel] = labelTexts2.map { text in
        let label = UILabel()
        label.text = text
        label.textAlignment = .right
        label.textColor = UIColor.picoBlue
        label.font = UIFont.picoDescriptionFont
        label.setContentHuggingPriority(.required, for: .horizontal)

        return label
    }

    private lazy var labelStackViews: [UIStackView] = {
        return (0..<3).map { index in
            let stackView = UIStackView(arrangedSubviews: [labels[index], dataLabels[index]])
            stackView.axis = .horizontal
            stackView.spacing = 24

            return stackView
        }
    }()

    private lazy var dataStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: labelStackViews)
        stackView.axis = .vertical
        stackView.spacing = 16

        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        addViews()
        makeConstraints()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addViews() {
        addSubview(dataStackView)
    }

    func makeConstraints() {
        let padding: CGFloat = 10

        dataStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(padding)
            make.leading.equalToSuperview().offset(padding)
            make.trailing.equalToSuperview().offset(-padding)
            make.bottom.equalToSuperview().offset(-padding)
        }
    }
}

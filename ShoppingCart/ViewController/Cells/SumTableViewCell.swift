//
//  SumTableViewCell.swift
//  ShoppingCart
//
//  Created by Oleksiy Chebotarov on 20/03/2025.
//

import Foundation
import UIKit

final class SumTableViewCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let sumLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        setupStyle()

        titleLabel.text = "Total amount in shopping cart:"
        sumLabel.text = "0€"
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(sumLabel)
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(4)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
    }

    private func setupStyle() {
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 18)
        titleLabel.textColor = .darkText

        sumLabel.numberOfLines = 0
        sumLabel.textAlignment = .center
        sumLabel.font = .systemFont(ofSize: 18)
        sumLabel.textColor = .darkText

        selectionStyle = .none
    }

    func configure(with sum: String) {
        sumLabel.text = sum
    }
}

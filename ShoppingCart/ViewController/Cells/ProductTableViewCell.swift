//
//  ProductTableViewCell.swift
//  ShoppingCart
//
//  Created by Oleksiy Chebotarov on 20/03/2025.
//

import UIKit

final class ProductTableViewCellViewModel {
    private let product: ProductToSell
    var quantity: Int

    var name: String { product.name }
    var price: String { "\(product.price) €" }
    var quantityText: String { "\(quantity)" }

    init(product: ProductToSell, quantity: Int) {
        self.product = product
        self.quantity = quantity
    }

    func updateQuantity(_ newQuantity: Int) {
        quantity = newQuantity
    }

    func getProductId() -> String {
        return product.id
    }

    func getProduct() -> ProductToSell {
        return product
    }
}

protocol ProductCellDelegate: AnyObject {
    func productCell(_ cell: ProductTableViewCell, didUpdateQuantity quantity: Int, for productId: String)
}

final class ProductTableViewCell: UITableViewCell {
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let stackView = UIStackView()
    private let countLabel = UILabel()
    private let minusButton = UIButton()
    private let plusButton = UIButton()

    private var viewModel: ProductTableViewCellViewModel?
    weak var delegate: ProductCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        setupStyle()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(minusButton)
        stackView.addArrangedSubview(countLabel)
        stackView.addArrangedSubview(plusButton)

        nameLabel.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview().inset(12)
        }

        priceLabel.snp.makeConstraints {
            $0.centerY.equalTo(nameLabel)
            $0.leading.equalTo(nameLabel.snp.trailing).offset(8)
        }

        stackView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-12)
            $0.centerY.equalTo(nameLabel)
            $0.leading.greaterThanOrEqualTo(priceLabel.snp.trailing).offset(4)
        }

        countLabel.snp.makeConstraints {
            $0.width.greaterThanOrEqualTo(30)
        }
    }

    private func setupStyle() {
        nameLabel.font = .systemFont(ofSize: 18)
        nameLabel.textColor = .darkText

        priceLabel.font = .systemFont(ofSize: 16)
        priceLabel.textColor = .darkText

        countLabel.font = .systemFont(ofSize: 18)
        countLabel.textColor = .darkText
        countLabel.textAlignment = .center

        minusButton.setTitle("-", for: .normal)
        minusButton.setTitleColor(.black, for: .normal)
        minusButton.addTarget(self, action: #selector(minusButtonTapped), for: .touchUpInside)

        plusButton.setTitle("+", for: .normal)
        plusButton.setTitleColor(.black, for: .normal)
        plusButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)

        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center
        selectionStyle = .none
    }

    @objc private func minusButtonTapped() {
        guard let viewModel = viewModel else { return }
        let newQuantity = max(0, viewModel.quantity - 1)
        viewModel.updateQuantity(newQuantity)
        updateUI()
        notifyDelegate()
    }

    @objc private func addButtonTapped() {
        guard let viewModel = viewModel else { return }
        let newQuantity = viewModel.quantity + 1
        viewModel.updateQuantity(newQuantity)
        updateUI()
        notifyDelegate()
    }

    private func notifyDelegate() {
        guard let viewModel = viewModel else { return }
        delegate?.productCell(self, didUpdateQuantity: viewModel.quantity, for: viewModel.getProductId())
    }

    private func updateUI() {
        guard let viewModel = viewModel else { return }
        nameLabel.text = viewModel.name
        priceLabel.text = viewModel.price
        countLabel.text = viewModel.quantityText
    }

    func configure(with viewModel: ProductTableViewCellViewModel) {
        self.viewModel = viewModel
        updateUI()
    }
}

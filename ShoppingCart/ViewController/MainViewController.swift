//
//  MainViewController.swift
//  ShoppingCart
//
//  Created by Oleksiy Chebotarov on 20/03/2025.
//

import SnapKit
import UIKit

enum DataSourceItem: Hashable, Sendable {
    case productSum(String)
    case cartItem(ProductToSell)
}

class MainViewController: UIViewController {
    var viewModel: ViewModelProtocol?
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let errorLabel = UILabel()
    private let retryButton = UIButton(type: .system)
    private let tableView = UITableView()
    private let buyButton = UIButton(type: .system)

    private var initialSnapshot = NSDiffableDataSourceSnapshot<String, DataSourceItem>()
    private lazy var dataSource: UITableViewDiffableDataSource<String, DataSourceItem> = {
        let dataSource = UITableViewDiffableDataSource<String, DataSourceItem>(tableView: tableView) { tableView, indexPath, item in
            switch item {
            case let .productSum(sumText):
                let cell = tableView.dequeueReusableCell(withIdentifier: SumTableViewCell.reuseIdentifier, for: indexPath) as! SumTableViewCell
                cell.configure(with: sumText)
                return cell

            case let .cartItem(product):
                let cell = tableView.dequeueReusableCell(withIdentifier: ProductTableViewCell.reuseIdentifier, for: indexPath) as! ProductTableViewCell
                let quantity = self.viewModel?.getQuantity(for: product.id) ?? 0
                let cellViewModel = ProductTableViewCellViewModel(product: product, quantity: quantity)
                cell.configure(with: cellViewModel)
                cell.delegate = self
                return cell
            }
        }
        return dataSource
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        requestData()
    }

    private func setupBindings() {
        viewModel?.onStateChange = { [weak self] state in
            self?.updateUI(for: state)
        }

        viewModel?.onPurchaseStateChange = { [weak self] state in
            self?.handlePurchaseState(state)
        }
    }

    private func requestData() {
        viewModel?.fetchRequest()
    }

    private func setupSnapshot() {
        var initialSnapshot = NSDiffableDataSourceSnapshot<String, DataSourceItem>()
        initialSnapshot.appendSections(["Section 1"])
        initialSnapshot.appendItems([.productSum("Sum Identifier")])
        dataSource.apply(initialSnapshot, animatingDifferences: false)
    }

    private func updateSnapshot(products: [ProductToSell], animation: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<String, DataSourceItem>()
        snapshot.appendSections(["Section 1"])
        let totalSum = viewModel?.calculateTotalSum() ?? 0
        snapshot.appendItems([.productSum("Total: \(String(format: "%.2f", totalSum)) €")], toSection: "Section 1")

        let productItems = products.map { DataSourceItem.cartItem($0) }
        snapshot.appendItems(productItems, toSection: "Section 1")

        dataSource.apply(snapshot, animatingDifferences: animation)
    }

    private func updateUI(for state: ProductLoadingState) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            switch state {
            case .initial:
                setLoadingState(isLoading: false)
                self.errorLabel.isHidden = true
                self.retryButton.isHidden = true
                self.setupSnapshot()
                self.updateBuyButtonState()

            case .loading:
                setLoadingState(isLoading: true)
                self.errorLabel.isHidden = true
                self.retryButton.isHidden = true

            case let .loaded(products):
                setLoadingState(isLoading: false)
                self.errorLabel.isHidden = true
                self.retryButton.isHidden = true
                self.updateSnapshot(products: products)
                self.updateBuyButtonState()

            case let .failed(error):
                self.setLoadingState(isLoading: false)
                self.errorLabel.text = "Error: \(error.localizedDescription)"
                self.errorLabel.isHidden = false
                self.retryButton.isHidden = false
            }
        }
    }

    private func handlePurchaseState(_ state: PurchaseState) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            switch state {
            case .initial:
                self.updateBuyButtonState()

            case .purchasing:
                self.activityIndicator.startAnimating()
                self.buyButton.isEnabled = false
                self.buyButton.alpha = 0.5

            case let .purchased(response):
                self.activityIndicator.stopAnimating()
                self.showAlert(title: "Success", message: response.message)
                self.clearCart()
                self.setupSnapshot()
                self.updateSnapshot(products: self.viewModel?.products ?? [], animation: false)
                self.updateBuyButtonState()

            case let .failed(error):
                self.activityIndicator.stopAnimating()
                self.showAlert(title: "Error", message: error.localizedDescription)
                self.updateBuyButtonState()
            }
        }
    }

    private func setLoadingState(isLoading: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.activityIndicator.isHidden = !isLoading
            self.tableView.isHidden = isLoading

            if isLoading {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
        }
    }

    private func updateBuyButtonState() {
        guard let viewModel = viewModel else { return }

        buyButton.isEnabled = viewModel.isBuyButtonEnable
        buyButton.alpha = viewModel.isBuyButtonEnable ? 1.0 : 0.5
    }

    @objc private func retryButtonTapped() {
        requestData()
    }

    @objc private func buyButtonTapped() {
        guard let viewModel = viewModel else { return }

        if viewModel.isCartEmpty {
            showAlert(title: "Error", message: "Your cart is empty. Add items to proceed with the purchase.")
            return
        }

        viewModel.purchaseProducts()
    }

    private func clearCart() {
        viewModel?.clearCart()
    }

    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.presentedViewController is UIAlertController {
                return
            }

            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}

private extension MainViewController {
    func setupUI() {
        title = "Shopping cart"
        view.backgroundColor = .white
        setupTableView()
        setupErrorLabel()
        setupRetryButton()
        setupBuyButton()
        setupActivityIndicator()
    }

    func setupTableView() {
        tableView.register(
            SumTableViewCell.self,
            forCellReuseIdentifier: SumTableViewCell.reuseIdentifier
        )
        tableView.register(
            ProductTableViewCell.self,
            forCellReuseIdentifier: ProductTableViewCell.reuseIdentifier
        )
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        tableView.separatorStyle = .none
    }

    func setupErrorLabel() {
        errorLabel.textColor = .red
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        view.addSubview(errorLabel)
        errorLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
        }
    }

    func setupRetryButton() {
        retryButton.setTitle("Retry", for: .normal)
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        view.addSubview(retryButton)
        retryButton.snp.makeConstraints { make in
            make.top.equalTo(errorLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
    }

    func setupBuyButton() {
        buyButton.setTitle("Buy", for: .normal)
        buyButton.backgroundColor = .systemBlue
        buyButton.setTitleColor(.white, for: .normal)
        buyButton.layer.cornerRadius = 8
        buyButton.addTarget(self, action: #selector(buyButtonTapped), for: .touchUpInside)
        buyButton.isEnabled = false
        buyButton.alpha = 0.5

        view.addSubview(buyButton)
        buyButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(50)
        }
    }

    func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .gray
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY)
        }
    }
}

extension MainViewController: ProductCellDelegate {
    func productCell(_: ProductTableViewCell, didUpdateQuantity quantity: Int, for productId: String) {
        viewModel?.updateQuantity(for: productId, newValue: quantity)
        updateTotalSumUI()
        updateBuyButtonState()
    }

    private func updateTotalSumUI() {
        guard let totalSum = viewModel?.calculateTotalSum() else { return }
        let sumItem = DataSourceItem.productSum("Total: \(String(format: "%.2f", totalSum)) €")

        var snapshot = dataSource.snapshot()
        let existingSumItems = snapshot.itemIdentifiers.filter {
            if case .productSum = $0 { return true }
            return false
        }

        snapshot.deleteItems(existingSumItems)
        snapshot.insertItems([sumItem], beforeItem: snapshot.itemIdentifiers(inSection: "Section 1").first!)

        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

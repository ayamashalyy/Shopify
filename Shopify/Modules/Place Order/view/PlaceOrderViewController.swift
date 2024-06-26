//
//  PlaceOrderViewController.swift
//  Shopify
//
//  Created by aya on 04/06/2024.
//

import UIKit

class PlaceOrderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var placeOrderButton: UIButton!
    var summaryCartCollectionView: UICollectionView!
    let couponImages = ["coupon2.jpg", "coupon2.jpg"]
    var viewModel = ShoppingCartViewModel()
    let homeViewModel = HomeViewModel()
    var orderViewModel = OrderViewModel.shared
    let settingsViewModel = SettingsViewModel()
    var selectedAddress: String?
    var selectedPhone: String?
    var selectedCountry: String?
    
    
    var grandTotal = 0.00
    var isUSD = true
    var settingVM = SettingsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        setupButtons()
        tableView.register(UINib(nibName: "PlaceOrderCell", bundle: nil), forCellReuseIdentifier: "PlaceOrderCell")
        fetchExchangeRates()
        setUpUI()
        
        viewModel.updateCartItemsHandler = { [weak self] in
            self?.summaryCartCollectionView.reloadData()
            self?.tableView.reloadData()
        }
        
        viewModel.fetchDraftOrders { error in
            if let error = error {
                print("Failed to fetch draft orders: \(error)")
            } else {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var  currency = settingVM.getSelectedCurrency()?.rawValue
        print(" currency\(currency)")
        if currency != "USD" {
            isUSD = false
            print("isUSD false\(isUSD) ")

        }
        else {
            print("isUSD true\(isUSD) ")

        }
        print("isUSD\(isUSD) ")
        
    }
    
    func fetchExchangeRates() {
        settingsViewModel.fetchExchangeRates { error in
            if let error = error {
                print("Failed to fetch exchange rates: \(error.localizedDescription)")
                return
            }
            self.tableView.reloadData()
            self.setUpUI()
        }
    }
    
    func setupButtons() {
        placeOrderButton.backgroundColor = UIColor(hex: "#FF7D29")
        placeOrderButton.setTitleColor(UIColor.white, for: .normal)
        placeOrderButton.layer.cornerRadius = 10
        placeOrderButton.clipsToBounds = true
    }
    
    func setUpUI() {
        let cartLayout = UICollectionViewFlowLayout()
        cartLayout.scrollDirection = .horizontal
        summaryCartCollectionView = UICollectionView(frame: .zero, collectionViewLayout: cartLayout)
        view.addSubview(summaryCartCollectionView)
        summaryCartCollectionView.translatesAutoresizingMaskIntoConstraints = false
        summaryCartCollectionView.contentInsetAdjustmentBehavior = .never
        summaryCartCollectionView.showsHorizontalScrollIndicator = false
        
        NSLayoutConstraint.activate([
            summaryCartCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 90),
            summaryCartCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            summaryCartCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            summaryCartCollectionView.heightAnchor.constraint(equalToConstant: 250)
            
        ])
        
        summaryCartCollectionView.backgroundColor = UIColor.clear
        summaryCartCollectionView.dataSource = self
        summaryCartCollectionView.delegate = self
        summaryCartCollectionView.register(SummaryCartCell.self, forCellWithReuseIdentifier: "SummaryCartCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceOrderCell", for: indexPath) as? PlaceOrderCell else {
            return UITableViewCell()
        }
        
        let selectedCurrency = settingsViewModel.getSelectedCurrency() ?? .USD
        let totalPrice = viewModel.cartItems.reduce(0) { $0 + ($1.4 != 45293432635640 ? $1.1 * $1.2 : 0) }
        let convertedTotalPriceString = settingsViewModel.convertPrice("\(totalPrice)" , to: selectedCurrency) ?? "\(totalPrice) USD"
        
        cell.subTotalLable.text = convertedTotalPriceString
        
        if let storedDiscountDict = homeViewModel.fetchStoredDiscountCode(),
           let discountPercentage = storedDiscountDict["priceRuleValue"] as? Int {
            let discountAmount = totalPrice * discountPercentage / 100
            let discountedTotal = totalPrice - discountAmount
            orderViewModel.storeTotalDiscount("\(discountAmount)")
            let convertedDiscountedTotalString = settingsViewModel.convertPrice("\(discountedTotal)" , to: selectedCurrency) ?? "\(discountedTotal) USD"
            
            cell.discountLable.text = "\(discountPercentage)%"
            
            let convertedGradeTotalString = settingsViewModel.convertPrice("\(discountedTotal + 5)" , to: selectedCurrency) ?? "\(discountedTotal + 5) USD"
            
            cell.gradeTotalLable.text = convertedGradeTotalString
//            print(" convertedGradeTotalString grandTotal in table view 1 with discount  convertedGradeTotalString \(convertedGradeTotalString)")
//            print("String(convertedGradeTotalString.dropLast(3))\(String(convertedGradeTotalString.dropLast(4)))")
//            print("Int(String(convertedGradeTotalString.dropLast(4)))\(Double(String(convertedGradeTotalString.dropLast(4))))")
            
            grandTotal = Double(String(convertedGradeTotalString.dropLast(4))) ?? 0.00
            
            print("grandTotal in table view 1 with discount  \(grandTotal)")

        } else {
            cell.discountLable.text = "0.0 %"
            let convertedGradeTotalString = settingsViewModel.convertPrice("\(totalPrice + 5)" , to: selectedCurrency) ?? "\(totalPrice + 5)USD"
            
            orderViewModel.storeTotalDiscount("")
            cell.gradeTotalLable.text = convertedGradeTotalString
         
            grandTotal = Double(String(convertedGradeTotalString.dropLast(4))) ?? 0.0
            
            print("grandTotal in table view 2 withooooout discount  \(grandTotal)")

        }
        
        let convertedShippingFeesString = settingsViewModel.convertPrice("\(5)" , to: selectedCurrency) ?? "\(5)USD"
        cell.shippingFeesLable.text = convertedShippingFeesString
        orderViewModel.storeTotalTax("\(5)")
        cell.cancelDiscountHandler = { [weak self] in
            self?.cancelDiscount(for: cell)
        }
        
        if let storedDiscountDict = self.homeViewModel.fetchStoredDiscountCode(),
           let storedCode = storedDiscountDict["code"] as? String {
            cell.couponLable.text = "\(storedCode)"
            cell.couponLable.isEnabled = false
        } else {
            cell.couponLable.text = "No discount code found"
        }
        cell.addressLabel.text = (selectedAddress ?? "") + "," + (selectedCountry ?? "")
        
        orderViewModel.storeShippingAddress((selectedAddress ?? "") + "," + (selectedCountry ?? ""))
        cell.phoneLabel.text = selectedPhone
        
        return cell
    }
    
    func cancelDiscount(for cell: PlaceOrderCell) {
        cell.isDiscountApplied.toggle()
        
        let totalPrice = viewModel.cartItems.reduce(0) { $0 + ($1.4 != 45293432635640 ? $1.1 * $1.2 : 0) }
        let selectedCurrency = settingsViewModel.getSelectedCurrency() ?? .USD
        
        if cell.isDiscountApplied {
            if let storedDiscountDict = homeViewModel.fetchStoredDiscountCode(),
               let discountPercentage = storedDiscountDict["priceRuleValue"] as? Int {
                let discountAmount = totalPrice * discountPercentage / 100
                let discountedTotal = totalPrice - discountAmount
                orderViewModel.storeTotalDiscount("\(discountAmount)")
                let convertedDiscountedTotalString = settingsViewModel.convertPrice("\(discountedTotal)" , to: selectedCurrency) ?? "\(discountedTotal) USD"
                
                cell.discountLable.text = "\(discountPercentage)%"
                let convertedGradeTotalString = settingsViewModel.convertPrice("\(discountedTotal + 5)" , to: selectedCurrency) ?? "\(discountedTotal + 5) USD"
                
                cell.gradeTotalLable.text = convertedGradeTotalString
                
                grandTotal = Double(String(convertedGradeTotalString.dropLast(4))) ?? 0.0
                   print("grandTotal in table view cell.isDiscountApplied \(grandTotal)")
                
                
                cell.updateDiscountPercentage(discountPercentage)
            }
        } else {
            cell.discountLable.text = "0.0 %"
            let convertedGradeTotalString = settingsViewModel.convertPrice("\(totalPrice + 5)" , to: selectedCurrency) ?? "\(totalPrice + 5) USD"
            
            orderViewModel.storeTotalDiscount("")
            cell.gradeTotalLable.text = convertedGradeTotalString
            
            grandTotal = Double(String(convertedGradeTotalString.dropLast(4))) ?? 0.0
            print("grandTotal in table view cell.isDiscountApplied elsssse \(grandTotal)")
         
            cell.updateDiscountPercentage(0)
        }
        
        cell.couponLable.isEnabled = false
     
    }
    
 
    
    
    @IBAction func placeOrder(_ sender: UIButton) {
        guard CheckNetworkReachability.checkNetworkReachability() else {
                   showNoInternetAlert()
                   return
               }
        
        let storyboard = UIStoryboard(name: "Second", bundle: nil)
        if let paymentViewController = storyboard.instantiateViewController(withIdentifier: "PaymentViewController") as? PaymentViewController {
            paymentViewController.modalPresentationStyle = .fullScreen
            paymentViewController.grandTotal = grandTotal
            paymentViewController.isUSD = isUSD
            present(paymentViewController, animated: true, completion: nil)
        }
    }
    

    @IBAction func backToSelectAddress(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    private func showNoInternetAlert() {
        let alert = UIAlertController(title: "No Internet Connection", message: "Please check your internet connection and try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}

extension PlaceOrderViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.cartItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SummaryCartCell", for: indexPath) as! SummaryCartCell
        let item = viewModel.cartItems[indexPath.item]
        let selectedCurrency = settingsViewModel.getSelectedCurrency() ?? .USD
        let convertedPriceString = settingsViewModel.convertPrice("\(item.1)", to: selectedCurrency) ?? "\(item.1)USD"
        cell.isHidden = item.4 == 45293432635640
        if !cell.isHidden {
            cell.configureCell(imageUrl: item.3, title: item.0, price: convertedPriceString, quantity: item.2)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 30, left: 16, bottom: 30, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 32, height: 200)
    }
}

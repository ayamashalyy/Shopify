//
//  BrandsViewController.swift
//  Shopify
//
//  Created by Rawan Elsayed on 04/06/2024.
//

import UIKit

class BrandsViewController: UIViewController {
    
    var productViewModel = ProductViewModel()
    let homeViewModel = HomeViewModel()
    
    @IBOutlet weak var sliderFilter: UISlider!
    
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!

    var brandProductsViewModel = BrandProductsViewModel()
    let settingsViewModel = SettingsViewModel()
    
    var categoriesCollectionView: UICollectionView!
    var valueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.indicator.startAnimating()
        setupUI()
    
        valueLabel.text = "10.0"
        
        sliderFilter.isHidden = true
        valueLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchProducts()
        fetchExchangeRates()
        checkNetworkConnection()
        
        
    }
    
    
    @IBAction func goToSearch(_ sender: UIBarButtonItem) {
      
        let storyboard = UIStoryboard(name: "third", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController {
            vc.comeFromHome = false
            let searchViewModel = SearchViewModel()
            searchViewModel.recevingProductFromANotherScreen = brandProductsViewModel.filteredProducts
            vc.searchViewModel = searchViewModel
            
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: false, completion: nil)
            
        }
    }
    
    func setupUI(){
        //view.backgroundColor = UIColor(hex: "#F5F5F5")
        
        let layout = UICollectionViewFlowLayout()
        categoriesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        view.addSubview(categoriesCollectionView)
        
        categoriesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        categoriesCollectionView.topAnchor.constraint(equalTo: sliderFilter.bottomAnchor, constant: 10).isActive = true
        categoriesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        categoriesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        categoriesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        
        categoriesCollectionView.backgroundColor = UIColor.clear
        categoriesCollectionView.dataSource = self
        categoriesCollectionView.delegate = self
        
        categoriesCollectionView.register(CustomCategoriesCell.self, forCellWithReuseIdentifier: "brandsCell")
        
        // Set the range for the slider
        sliderFilter.minimumValue = 10.0
        sliderFilter.maximumValue = 500.0
        
        //Add target for value changed event
        sliderFilter.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        
        // Label setup
        valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(valueLabel)
        
        // Constraints for label
        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: categoriesCollectionView.topAnchor, constant: -30),
            valueLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            valueLabel.trailingAnchor.constraint(equalTo: sliderFilter.leadingAnchor, constant: -10),
        ])
    }
    
    func fetchProducts() {
        brandProductsViewModel.fetchProducts{ [weak self] error in
            guard let self = self else { return }
            self.indicator.stopAnimating()
            self.indicator.isHidden = true
            if let error = error {
                print("Error fetching products: \(error)")
            } else {
                self.categoriesCollectionView.reloadData()
            }
        }
    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    
    @IBAction func filterByPrice(_ sender: UIBarButtonItem) {
        sliderFilter.isHidden.toggle()
        valueLabel.isHidden.toggle()
        
        if !sliderFilter.isHidden {
            filterProductsByCurrentSliderValue()
        }
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        let currentValue = String(format: "%.2f", sender.value)
        valueLabel.text = "\(currentValue)"
        
        filterProductsByCurrentSliderValue()
    }
    
    func filterProductsByCurrentSliderValue() {
        if let currentValue = Float(valueLabel.text ?? "10.0") {
            print("Filtering products by price: \(currentValue)")
            brandProductsViewModel.filterProducts(byPrice: currentValue)
            categoriesCollectionView.reloadData()
            print("Reloaded collection view with filtered products.")
        }
    }
    
    func fetchExchangeRates(){
        settingsViewModel.fetchExchangeRates { [weak self] error in
            if let error = error {
                print("Error fetching exchange rates: \(error)")
            } else {
                // Reload data once exchange rates are fetched
                self?.categoriesCollectionView.reloadData()
            }
        }
    }
    
    private func checkNetworkConnection() {
        if !homeViewModel.isNetworkReachable() {
            showNoInternetAlert()
        }
    }

    private func showNoInternetAlert() {
        let alert = UIAlertController(title: "No Internet Connection", message: "Please check your internet connection and try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

extension BrandsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CustomCategoriesCellDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return brandProductsViewModel.numberOfProducts()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = categoriesCollectionView.dequeueReusableCell(withReuseIdentifier: "brandsCell", for: indexPath) as! CustomCategoriesCell
        
        if let product = brandProductsViewModel.product(at: indexPath.row) {
            
            print("Displaying product: \(product.name) with price: \(product.variants.first?.price ?? "N/A")")
            cell.nameCategoriesLabel.text = product.name
            
            if let selectedCurrency = settingsViewModel.getSelectedCurrency(),
               let convertedPrice = settingsViewModel.convertPrice(product.variants.first?.price ?? "N/A", to: selectedCurrency) {
                cell.priceLabel.text = convertedPrice
            } else {
                cell.priceLabel.text = "\(product.variants.first?.price ?? "0") EGP"
            }
            
            if let imageUrlString = product.images.first?.url, let imageUrl = URL(string: imageUrlString) {
                cell.categoriesImgView.kf.setImage(with: imageUrl)
            } else {
                cell.categoriesImgView.image = UIImage(named: "splash-img.jpg")
            }

            if product.variants[0].isSelected {
                print("is fav ")
                cell.heartButton.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
            } else {
                print("is not fav")
                cell.heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
            }
        }
        
        cell.heartButton.tag = indexPath.row
        cell.delegate = self
        
        return cell
    }
    
    
    
    func didTapHeartButton(in cell: CustomCategoriesCell) {
        if let indexPath = categoriesCollectionView.indexPath(for: cell) {
            guard let product = brandProductsViewModel.product(at: indexPath.row) else {
                return
            }
            
            if Authorize.isRegistedCustomer() {
                cell.heartButton.isEnabled = false
                if product.variants[0].id != fakeProductInDraftOrder {
                    // deafult now if false
                    if product.variants[0].isSelected {
                        // Remove from fav
                        showAlertWithTwoOption(message: "Are you sure you want to remove from favorites?",
                                               okAction: { [weak self] _ in
                            print("OK button remove tapped")
                            self?.productViewModel.removeFromFavDraftOrders(VariantsId: product.variants[0].id) { isSuccess in
                                DispatchQueue.main.async {
                                    if isSuccess {
                                        product.variants[0].isSelected = false
                                        cell.heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
                                        cell.heartButton.isEnabled = true
                                        print("remove succeful")
                                    } else {
                                        self?.showAlertWithTwoOption(message: "Failed to remove from favorites")
                                        cell.heartButton.isEnabled = true
                                    } } }
                        }, cancelAction: { _ in
                            cell.heartButton.isEnabled = true
                        } )
                    } else {
                        // Add to fav
                        productViewModel.addToFavDraftOrders(selectedVariantsData: [(product.variants[0].id, product.images.first?.url ?? "", 1)]) { [weak self] isSuccess in
                            DispatchQueue.main.async {
                                if isSuccess {
                                    cell.heartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                                    cell.heartButton.isEnabled = true
                                    print("added succesfully ")
                                    product.variants[0].isSelected = true
                                    self?.showCheckMarkAnimation(mark: "heart.fill")
                                    
                                } else {
                                    self?.showAlertWithTwoOption(message: "Failed to add to favorites")
                                    cell.heartButton.isEnabled = true
                                }
                            }
                        }
                    }
                } else {
                    showAlert(message: "Sorry ,failed to handle favourite status of this product...check another products")

                }} else {
                    self.showAlertWithTwoOptionOkayAndCancel(message: "Login to add to faviourts?",
                                                             okAction: { action in
                        Navigation.ToALogin(from: self)
                        print("OK button tapped")
                    }
                    )
                }
            }
    }
    
    private func showAlert(message: String, action: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: action)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func showAlertWithTwoOptionOkayAndCancel(message: String, okAction: ((UIAlertAction) -> Void)? = nil, cancelAction: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        
        let okAlertAction = UIAlertAction(title: "Okay", style: .default, handler: okAction)
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelAction)
        
        alertController.addAction(okAlertAction)
        alertController.addAction(cancelAlertAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func showAlertWithTwoOption(message: String, okAction: ((UIAlertAction) -> Void)? = nil, cancelAction: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "Delete", style: .destructive, handler: okAction)
        alertController.addAction(okAlertAction)
        
        if let cancelAction = cancelAction {
            let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelAction)
            alertController.addAction(cancelAlertAction)
        }
        
        present(alertController, animated: true, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width / 2 - 20 , height: 260)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if !homeViewModel.isNetworkReachable() {
            showNoInternetAlert()
            return
        }else{
            if let product = brandProductsViewModel.product(at: indexPath.row)
            {
                Navigation.ToProduct(productId: "\(product.id)", from: self)
                
            }
        }
    }
    
}














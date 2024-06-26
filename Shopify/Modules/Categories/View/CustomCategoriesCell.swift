import UIKit

protocol CustomCategoriesCellDelegate: AnyObject {
    func didTapHeartButton(in cell: CustomCategoriesCell)
}

class CustomCategoriesCell: UICollectionViewCell {

    let categoriesImgView = UIImageView()
    let nameCategoriesLabel = UILabel()
    let priceLabel = UILabel()
    let heartButton = UIButton()
    
    weak var delegate: CustomCategoriesCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupUI() {
        contentView.addSubview(categoriesImgView)
        contentView.addSubview(nameCategoriesLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(heartButton)
        categoriesImgView.translatesAutoresizingMaskIntoConstraints = false
        nameCategoriesLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        heartButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            categoriesImgView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            categoriesImgView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            categoriesImgView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            categoriesImgView.heightAnchor.constraint(equalToConstant: 100),
            categoriesImgView.bottomAnchor.constraint(equalTo: nameCategoriesLabel.topAnchor),

            nameCategoriesLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            nameCategoriesLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            nameCategoriesLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -25),

            priceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            priceLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            priceLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),

            heartButton.centerYAnchor.constraint(equalTo: nameCategoriesLabel.centerYAnchor),
            heartButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            heartButton.widthAnchor.constraint(equalToConstant: 24),
            heartButton.heightAnchor.constraint(equalToConstant: 24)
        ])

        nameCategoriesLabel.textAlignment = .left
        nameCategoriesLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        nameCategoriesLabel.numberOfLines = 0
        nameCategoriesLabel.lineBreakMode = .byWordWrapping

        priceLabel.textAlignment = .left
        priceLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        priceLabel.textColor = UIColor(hex: "#FF7D29")
        categoriesImgView.layer.cornerRadius = 20
        categoriesImgView.layer.masksToBounds = true
        categoriesImgView.contentMode = .scaleAspectFit 
        
        contentView.layer.masksToBounds = true
        contentView.clipsToBounds = false
        contentView.layer.cornerRadius = 8
        contentView.backgroundColor = .white
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
        contentView.layer.shadowRadius = 5
        contentView.layer.shadowOpacity = 0.2

        // Add a background color to debug the heart button position
        heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
        //heartButton.backgroundColor = UIColor.red.withAlphaComponent(0.5) // Red color for debugging
        heartButton.addTarget(self, action: #selector(heartButtonTapped), for: .touchUpInside)
        heartButton.isUserInteractionEnabled = true
     //   heartButton.tintColor = .red
        
        bringSubviewToFront(heartButton)
    }

    @objc func heartButtonTapped(_ sender: UIButton) {
        delegate?.didTapHeartButton(in: self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.shadowPath = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
    }
}

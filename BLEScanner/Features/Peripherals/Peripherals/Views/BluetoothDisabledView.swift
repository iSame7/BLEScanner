//
//  ErrorView.swift
//  Peripherals
//
//  Created by Sameh Mabrouk on 16/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import UIKit

class BluetoothDisabledView: UIView {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "bluetooth"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var titlelabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .center
        label.text = "BLEScanner requires Bluetooth"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var subTitlelabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.text = "Please enable Bluetooth to continue using this app"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Setup UI

extension BluetoothDisabledView {
    
    func setupUI() {
        setupSubViews()
        setupConstraints()
        backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
    }
    
    func setupSubViews() {
        addSubview(imageView)
        addSubview(titlelabel)
        addSubview(subTitlelabel)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -50),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 100),

            titlelabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titlelabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            titlelabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            
            subTitlelabel.topAnchor.constraint(equalTo: titlelabel.bottomAnchor, constant: 8),
            subTitlelabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            subTitlelabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16)
        ])
    }
}

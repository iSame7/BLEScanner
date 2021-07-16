//
//  PeripheralCell.swift
//  Peripherals
//
//  Created by Sameh Mabrouk on 12/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import UIKit
import Core

class PeripheralCell : UITableViewCell, Dequeueable {
    
    private lazy var peripheralNameLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var signalStrengthLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var signalStrengthImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "signal_strength_0"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    func configure(withPeripheralName peripheralName: String, signalStrength: String, signalStengthImage: UIImage) {
        peripheralNameLabel.text = peripheralName
        
        guard let rssi = Int(signalStrength) else {
            return
        }
        
        if Int(signalStrength) == 127 {
            signalStrengthLabel.text = "---"
        } else {
            signalStrengthLabel.text = signalStrength
        }
        
        switch labs(rssi) {
        case 0...40:
            signalStrengthImageView.image = #imageLiteral(resourceName: "signal_strength_5")
        case 41...53:
            signalStrengthImageView.image = #imageLiteral(resourceName: "signal_strength_4")
        case 54...65:
            signalStrengthImageView.image = #imageLiteral(resourceName: "signal_strength_3")
        case 66...77:
            signalStrengthImageView.image = #imageLiteral(resourceName: "signal_strength_2")
        case 77...89:
            signalStrengthImageView.image = #imageLiteral(resourceName: "signal_strength_1")
        default:
            signalStrengthImageView.image = #imageLiteral(resourceName: "signal_strength_0")
        }        
    }
}

// MARK: - Setup UI

private extension PeripheralCell {
    
    func setupUI() {
        selectionStyle = .none
        backgroundColor = .white
        setupSubviews()
        setupConstraints()
    }
    
    func setupSubviews() {
        addSubview(signalStrengthImageView)
        addSubview(signalStrengthLabel)
        addSubview(peripheralNameLabel)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            signalStrengthImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            signalStrengthImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            signalStrengthImageView.widthAnchor.constraint(equalToConstant: 23),
            
            peripheralNameLabel.leadingAnchor.constraint(equalTo: signalStrengthImageView.leadingAnchor, constant: 40),
            peripheralNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            peripheralNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            signalStrengthLabel.leadingAnchor.constraint(equalTo: signalStrengthImageView.leadingAnchor),
            signalStrengthLabel.topAnchor.constraint(equalTo: signalStrengthImageView.bottomAnchor, constant: 6),
            signalStrengthLabel.trailingAnchor.constraint(equalTo: peripheralNameLabel.leadingAnchor, constant: 0),
            signalStrengthLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
}


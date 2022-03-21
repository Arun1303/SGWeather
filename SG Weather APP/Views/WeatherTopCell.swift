//
//  WeatherTopCell.swift
//  SG Weather APP
//
//  Created by Prabal on 21/03/22.
//

import UIKit

class WeatherTopCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
        constraintSetup()
     }

     required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
    
    lazy var temperatureLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 85, weight: .ultraLight)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    lazy var cityLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 25, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    lazy var weatherImageView : UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

   
    
    func constraintSetup() {
        contentView.addSubview(temperatureLabel)
        contentView.addSubview(cityLabel)
        contentView.addSubview(weatherImageView)
        let margineGuide = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            weatherImageView.topAnchor.constraint(equalTo: margineGuide.topAnchor, constant: 0),
            weatherImageView.widthAnchor.constraint(equalToConstant: 100),
            weatherImageView.heightAnchor.constraint(equalToConstant: 100),
            weatherImageView.centerXAnchor.constraint(equalTo: margineGuide.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            temperatureLabel.topAnchor.constraint(equalTo: weatherImageView.bottomAnchor, constant: 0),
            temperatureLabel.widthAnchor.constraint(equalToConstant: 350),
            temperatureLabel.heightAnchor.constraint(equalToConstant: 75),
            temperatureLabel.centerXAnchor.constraint(equalTo: margineGuide.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            cityLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 0),
            cityLabel.widthAnchor.constraint(equalToConstant: 200),
            cityLabel.heightAnchor.constraint(equalToConstant: 150),
            cityLabel.centerXAnchor.constraint(equalTo: margineGuide.centerXAnchor)
        ])

       
    }

}

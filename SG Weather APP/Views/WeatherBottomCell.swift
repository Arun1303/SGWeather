//
//  WeatherBottomCell.swift
//  SG Weather APP
//
//  Created by Prabal on 21/03/22.
//

import UIKit

class WeatherBottomCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
        let stackView   = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.horizontal
        stackView.distribution  = UIStackView.Distribution.fill
        stackView.alignment = UIStackView.Alignment.fill
        stackView.spacing   = 5.0

        stackView.addArrangedSubview(dayLabel)
        stackView.addArrangedSubview(weatherImageView)
        stackView.addArrangedSubview(conditionLabel)
        stackView.addArrangedSubview(tempLabel)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        self.contentView.addSubview(stackView)

        //Constraints
        stackView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,constant: 10).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor,constant: -10).isActive = true
//        constraintSetup()
     }

     required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
    lazy var dayLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 17, weight: .light)
        label.textColor = .black
        return label
    }()
    
    lazy var conditionLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 17, weight: .light)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    lazy var tempLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 17, weight: .light)
        label.textColor = .black
        
        return label
    }()
    
    lazy var weatherImageView : UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    

}

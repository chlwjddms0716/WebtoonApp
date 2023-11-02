//
//  TextImageView.swift
//  WebtoonApp
//
//  Created by 최정은 on 11/2/23.
//

import UIKit

class TextImageView : UIStackView {
    
    private let imageView: UIImageView = {
       let imageView = UIImageView()
        return imageView
    }()
    
    private let textLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = UIColor(hexCode: Color.TextGrayColor)
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    init(image: String, text: String) {
        super.init(frame: .zero)
        
        addViews()
        configureUI(image: image, text: text)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews(){
        self.addArrangedSubview(imageView)
        self.addArrangedSubview(textLabel)
    }
    
    private func configureUI(image: String, text: String){
        self.spacing = 20
        self.axis = .vertical
        self.alignment = .center
        self.isHidden = true
        
        imageView.image = UIImage(named: image)
        textLabel.text = text
    }
}


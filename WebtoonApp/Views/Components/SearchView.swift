//
//  SearchView.swift
//  WebtoonApp
//
//  Created by 최정은 on 11/2/23.
//

import UIKit

class SearchView: UIStackView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return UIStackView.layoutFittingExpandedSize
    }
}

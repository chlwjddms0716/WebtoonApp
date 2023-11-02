//
//  Constants.swift
//  WebtoonApp
//
//  Created by 최정은 on 10/31/23.
//

import Foundation

struct APIInfo {
    
    private init(){}
    
    static let URL = "https://korea-webtoon-api.herokuapp.com"
    static let LimitNum = 30
}

struct Cell {
    
    static let WebtoonTypeCellHeight:CGFloat = 50
    
    static let WebtoonCellLineHeight: CGFloat = 5
    static let WebtoonCellImageSpace: CGFloat = 20
    
    static let WebtoonImageWidth: CGFloat = 90
    static let WebtoonImageHeight: CGFloat = 125
    
    static let SearchCellHeight: CGFloat = 56
}

struct Color {
    private init(){}
    
    static let BackColor = "FBFBFB"
    static let KeywordBackColor = "F4E4E2"
    
    static let GrayColor = "F2F2F2"
    static let TextGrayColor = "757575"
    static let TextFieldBackColor = "F7F7F7"
    
    static let arrowColor = "9DA7AB"
}


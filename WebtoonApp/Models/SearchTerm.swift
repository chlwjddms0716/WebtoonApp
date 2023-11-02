//
//  SearchTerm.swift
//  WebtoonApp
//
//  Created by 최정은 on 11/2/23.
//

import Foundation

public struct SearchTerm: Decodable {
    var id: Int
    var keyword: String
    var timestamp: Int
}

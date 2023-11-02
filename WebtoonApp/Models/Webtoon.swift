//
//  Webtoon.swift
//  WebtoonApp
//
//  Created by 최정은 on 10/31/23.
//

import Foundation

// MARK: - WebtoonData
struct WebtoonData: Codable {
    let lastUpdate: String?
    let totalWebtoonCount, naverWebtoonCount, kakaoWebtoonCount, kakaoPageWebtoonCount: Int?
    let updatedWebtoonCount, createdWebtoonCount: Int?
    let webtoons: [Webtoon]?
}

// MARK: - Webtoon
struct Webtoon: Codable {
    let id: String?
    let webtoonID: Int?
    let title, author: String?
    let url: String?
    let img: String?
    let service: String?
    let updateDays: [String]?
    let fanCount: Int?
    let additional: Additional?
    let searchKeyword: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case webtoonID = "webtoonId"
        case title, author, url, img,  fanCount, searchKeyword
        case service, updateDays, additional
    }
    
    var type: WebtoonType {
        guard let service = service, let type  = WebtoonType.allCases.first(where: {"\($0)" == service}) else { return .naver }
        return type
    }
 
    var updatedayList: [UpdateDay] {
        guard let updateDays = updateDays else { return [] }
        var array: [UpdateDay] = []
        array = updateDays.map { item in
            let day =  UpdateDay.allCases.first(where: { "\($0)" == item})
            return day ?? .finished
       }
        array = array.count >= 7 ? [UpdateDay.day] : array
        return array
    }
}

// MARK: - Additional
struct Additional: Codable {
    let new, rest, up, adult: Bool?
    let singularityList: [String]?
}

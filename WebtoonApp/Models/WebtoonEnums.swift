//
//  WebtoonEnums.swift
//  WebtoonApp
//
//  Created by 최정은 on 10/31/23.
//

import Foundation

enum WebtoonType: String, CaseIterable, Decodable {
    case  naver = "네이버 웹툰"
    case  kakao = "카카오 웹툰"
    case  kakaoPage = "카카오페이지"
}

enum UpdateDay: String, CaseIterable {
    
    case  mon = "월"
    case  tue  = "화"
    case  wed = "수"
    case  thu = "목"
    case  fri = "금"
    case  sat = "토"
    case  sun = "일"
    case  day = "매일"
    case  finished = "완결"
    case  naverDaily = "네이버 Daily+"
}

enum  Singularity: String {
    case over15 = "15세 이상"
    case  free = "완전 무료"
    case  waitFree = "기다리면 무료"
}

enum TextViewData {
    case emptyHistory
    case emptyWebtoon
    
    var info: (image: String, text: String) {
        switch self {
        case .emptyHistory :
            return ("RecentIllust", "웹툰의 제목, 작가 또는 웹툰 정보에 포함된\n단어 또는 문장을 검색해 주세요.")
        case .emptyWebtoon :
            return ("EmptyResultIllust", "검색 결과가 없습니다.\n다른 검색어를 입력해 보세요.")
        }
    }
}

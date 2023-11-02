//
//  SearchViewModel.swift
//  WebtoonApp
//
//  Created by 최정은 on 10/31/23.
//

import Foundation
import RxSwift

enum ViewStatus {
    case NoExistSearchHistory // 검색기록 없음
    case ExistSearchHistory // 검색기록 있음
    case CompleteSearch // 검색 완료
    case CompleteSearchNoExist // 검색 완료 -> 게시글 없음
}

class SearchViewModel {
    
    let disposeBag = DisposeBag()
    // INPUT
    let fetchHistory: AnyObserver<Void>
    let removeHistory: AnyObserver<SearchTerm>
    let searchKeyword: AnyObserver<String>
    let changeType: AnyObserver<ViewStatus>
    
    // OUTPUT
    let historys: Observable<[SearchTerm]>
    let allPosts: Observable<[Webtoon]>
    let boardTitle: Observable<WebtoonType>
    let viewType: Observable<ViewStatus>
    
    init(_ selectedType: WebtoonType) {
        SqLiteManager.shared.createTable()
        
        let changing = BehaviorSubject<ViewStatus>(value: .NoExistSearchHistory)
        
        let board = BehaviorSubject<WebtoonType>(value: selectedType)
        
        let fetchingHistory = PublishSubject<[SearchTerm]>() // 검색기록 전달
        let fetching = PublishSubject<Void>() // 검색기록 다시 가져오기
        let removing = PublishSubject<SearchTerm>() // 검색기록 삭제
        let searching = PublishSubject<String>() // 검색하기
        
        let fetchingPost = PublishSubject<[Webtoon]>()
                
        changeType = changing.asObserver()
        viewType = changing
        
        boardTitle = board
        
        historys = fetchingHistory
        
        allPosts = fetchingPost
        
        fetchHistory = fetching.asObserver()
        // 검색기록 보내기
        fetching.subscribe(onNext: {
            let data = SqLiteManager.shared.readData()
            fetchingHistory.onNext(data)
        })
        .disposed(by: disposeBag)
        
        removeHistory = removing.asObserver()
        // 검색기록 지우기
        removing.subscribe(onNext: { history in
            SqLiteManager.shared.deleteData(id: history.id)
        })
        .disposed(by: disposeBag)
        
        searchKeyword = searching.asObserver()
        // 검색기록 추가, 검색어 전달, 검색 API 호출
        searching.subscribe(onNext: {  data in
            SqLiteManager.shared.insertData(keyword: data)
           
            WebtoonService.shared.getWebtoonByKeyword(keyword: data)
                .subscribe(onNext: {  webtoonData in
                    guard let webtoons = webtoonData.webtoons else { return }
                    let array = webtoons.filter{ $0.type == selectedType}
                    fetchingPost.onNext(array)
                }, onError: { error in
                    print("getWebtoonByKeyword Error : ", error)
                })
                .disposed(by: self.disposeBag)
        })
        .disposed(by: disposeBag)
    }
}



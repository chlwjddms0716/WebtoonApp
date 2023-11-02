//
//  MainViewModel.swift
//  WebtoonApp
//
//  Created by 최정은 on 10/31/23.
//

import Foundation
import RxSwift

class MainViewModel {
   
    let disposeBag = DisposeBag()
    
    // Paging 처리를 위한 변수
    var offset: Int = 0
    var selectedType: WebtoonType?
    var isPaging = false
    
    //INPUT
    let tapServicePage: AnyObserver<Void> // 서비스 선택 페이지 버튼 클릭
    let selectWebtoonType: AnyObserver<WebtoonType> // 서비스클릭 선택
    let pagingWebtoon: AnyObserver<Void> // 스크롤 시
    let setFooter: AnyObserver<Bool> // 스피너뷰가 표시되야 할 때
    
    // OUTPUT
    let showWebtoonTypePage: Observable<Void> // 서비스 페이지 표시
    let selectedWebtoonType: Observable<WebtoonType> // 표시해야될 서비스명, 다른 페이지에서 서비스 선택
    let allWebtoons: Observable<[Webtoon]> // 웹툰 표시
    let showFooter: Observable<Bool> // 스피너뷰 표시
    
    init() {
        let showing = PublishSubject<Void>()  // 서비스 선택 페이지
        let selecting = BehaviorSubject<WebtoonType>(value: .naver) // 서비스 선택한 아이템
        
        let fetching = PublishSubject<([Webtoon], Int)>() // 웹툰 표시
        let paging = PublishSubject<Void>() // 웹툰 페이징 처리
        
        let showingFooter = BehaviorSubject<Bool>(value: false) // 페이징 처리에 따른 스피너뷰 표시여부
        
        allWebtoons = fetching.map({ post, totalCount in
            return post
        })

        tapServicePage = showing.asObserver()
        showWebtoonTypePage = showing
        
        selectedWebtoonType = selecting
        selectWebtoonType = selecting.asObserver()
        
        pagingWebtoon = paging.asObserver()
        
        setFooter = showingFooter.asObserver()
        showFooter = showingFooter.distinctUntilChanged()
        
        paging
            .withLatestFrom(fetching.asObservable())
            .filter { (preWebtoons, totalCount) in
                return preWebtoons.count < totalCount && !self.isPaging
            }
            .map { (prePosts, totalCount) in return prePosts }
            .subscribe(onNext: { [weak self] prePosts in
                guard let self = self, let type = selectedType else { return }
                isPaging = true
                offset += 1
                setFooter.onNext(true)
                
                WebtoonService.shared.getWebtoonByService(service: type, page: offset)
                    .subscribe(onNext: { [weak self]  webtoonData in
                        guard let safeData = webtoonData.webtoons, let self = self else { return }
                        
                        var count: Int = 0
                        switch selectedType {
                        case .kakao :
                            count =  webtoonData.kakaoPageWebtoonCount ?? 0
                        case .naver :
                            count = webtoonData.naverWebtoonCount ?? 0
                        case .kakaoPage :
                            count = webtoonData.kakaoPageWebtoonCount ?? 0
                        case .none:
                            count = 0
                        }
                        
                        fetching.onNext((prePosts + safeData, count))
                        setFooter.onNext(false)
                        isPaging = false
                    }, onError: { error in
                        print("getWebtoonByService Error : ", error)
                    })
                    .disposed(by: (disposeBag))
            })
            .disposed(by: disposeBag)
        
        //
        selectedWebtoonType.subscribe(onNext: { [weak self]  type in
            guard let self = self else { return }
            WebtoonService.shared.getWebtoonByService(service: type)
                .subscribe(onNext: { [weak self] webtoonData in
                    self?.selectedType = type
                    guard let data = webtoonData.webtoons else { return }
                    
                    var count: Int = 0
                    switch type {
                    case .kakao :
                        count =  webtoonData.kakaoPageWebtoonCount ?? 0
                    case .naver :
                        count = webtoonData.naverWebtoonCount ?? 0
                    case .kakaoPage :
                        count = webtoonData.kakaoPageWebtoonCount ?? 0
                    }
                    
                    fetching.onNext(( data, count))
                })
                .disposed(by: self.disposeBag)
            
        })
        .disposed(by: disposeBag)
        
    }
}

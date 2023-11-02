//
//  TypeSelectViewModel.swift
//  WebtoonApp
//
//  Created by 최정은 on 10/31/23.
//

import Foundation
import RxSwift

class TypeSelectViewModel {
    
    let disposeBag = DisposeBag()
    
    // INPUT
    var selectBoard: AnyObserver<WebtoonType>
    
    // OUTPUT
    let boardItems: Observable<[WebtoonType]>
    let closePage: Observable<WebtoonType>

    init() {
        boardItems = Observable.just(WebtoonType.allCases)
        
        let selectItem = PublishSubject<WebtoonType>()
        selectBoard = selectItem.asObserver()
        closePage = selectItem
    }
}

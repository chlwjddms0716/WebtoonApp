//
//  WebtoonService.swift
//  WebtoonApp
//
//  Created by 최정은 on 10/31/23.
//

import Foundation
import RxSwift
import Alamofire

public struct WebtoonService {
    
    static let shared = WebtoonService()
    private init(){}
  
    func getWebtoonByService(service: WebtoonType, page: Int = 0) -> Observable<WebtoonData> {
        return Observable.create { observer in
            AF.request(WebtoonAPI.getWebtoonByService(service: "\(service)", perPage: APIInfo.LimitNum, page: page))
                .responseDecodable(of: WebtoonData.self) { response in
                    switch response.result {
                    case .success(let data):
                        observer.onNext(data)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            
            return Disposables.create()
        }
    }
    
    func getWebtoonByKeyword(keyword: String) -> Observable<WebtoonData> {
        return Observable.create { observer in
            AF.request(WebtoonAPI.getWebtoonsByKeyword(keyword: keyword))
                .responseDecodable(of: WebtoonData.self) { response in
                    switch response.result {
                    case .success(let data):
                        observer.onNext(data)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            
            return Disposables.create()
        }
    }
}

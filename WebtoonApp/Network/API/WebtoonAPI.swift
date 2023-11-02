//
//  WebtoonAPI.swift
//  WebtoonApp
//
//  Created by 최정은 on 10/31/23.
//

import Foundation
import Alamofire

public enum WebtoonAPI{
    case getWebtoonByService(service: String, perPage: Int, page: Int)
    case getWebtoonsByKeyword(keyword: String)
}

extension WebtoonAPI: Router, URLRequestConvertible {
    
    public var baseURL: String {
        return APIInfo.URL
    }
    
    public var path: String {
        switch self {
        case let .getWebtoonByService(service, perPage, page):
            return "?service=\(service)&perPage=\(perPage)&page=\(page)"
        case let .getWebtoonsByKeyword(keyword) :
            return "/search?keyword=\(keyword)"
        }
    }
    
    public var method: HTTPMethod {
        return .get
    }
    
    public var headers: [String : String] {
        return [
            "Content-Type": "application/json",
        ]
    }
    
    public var parameters: [String : Any]? {
        return nil
    }
    
    public var encoding: ParameterEncoding? {
        return nil
    }
    
    public func asURLRequest() throws -> URLRequest {
        let url = URL(string: baseURL + path)
        var request = URLRequest(url: url!)
        
        request.method = method
        request.headers = HTTPHeaders(headers)
        
        if let encoding = encoding {
            return try encoding.encode(request, with: parameters)
        }
        
        return request
    }
}

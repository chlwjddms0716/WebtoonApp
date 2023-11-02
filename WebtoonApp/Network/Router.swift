//
//  Router.swift
//  WebtoonApp
//
//  Created by 최정은 on 10/31/23.
//

import Foundation
import Alamofire

public protocol Router {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var parameters: [String: Any]? { get }
    var encoding: ParameterEncoding? { get }
}

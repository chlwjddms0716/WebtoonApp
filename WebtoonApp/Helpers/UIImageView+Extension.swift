//
//  UIImageView+Extension.swift
//  WebtoonApp
//
//  Created by 최정은 on 11/2/23.
//

import UIKit
import Alamofire


extension UIImageView {
    func load(url: String?) {
        
        guard let url = url else { return }
        
        var urlString = url
        if !urlString.contains("http") && !urlString.contains("https") {
            urlString = "https:" + url
        }
        
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("app", forHTTPHeaderField: "userAgent")
        request.setValue("https://search.naver.com/", forHTTPHeaderField: "Referer")
      
        AF.request(request)
            .response{ response in
                switch response.result{
                case .success(let data) :
                    if let data = data {
                        if let image = UIImage(data: data){
                            self.image = image
                        }
                    }
                case .failure(let error) :
                    print("loadAsyncImage : ",error.localizedDescription)
                }
            }
    }
}

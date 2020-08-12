//
//  ConnectionManager.swift
//  cat-gallery
//
//  Created by Otávio Souza on 11/08/20.
//  Copyright © 2020 otavioses. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift
import RxAlamofire
import CommonCrypto
import SwiftyJSON

protocol ConnectionManagerProcotol {
    func getList() throws -> Observable<JSON>
}

class ConnectionManager: ConnectionManagerProcotol {
    
    let urlBase = "https://api.imgur.com"
    let listApi = "/3/gallery/search"
    
    func getList() throws -> Observable<JSON>   {
        let parameters =
            Parameters(
                dictionaryLiteral:
                ("q", "cats"))
                
        let headers = HTTPHeaders(
            dictionaryLiteral:
            ("Authorization", "Client-ID \(SafePlace.clientId)"),
            ("Content-Type", "application/json; charset=utf-8"))
        
        let finalUrl = "\(urlBase)\(listApi)"
        
        return get(finalUrl, parameters, headers)
    }
    
    private func get(_ finalUrl: String, _ parameters: Parameters, _ headers: HTTPHeaders) -> Observable<JSON> {
        return Observable<JSON>.create { (observer) -> Disposable in
            AF.request(finalUrl, method: .get, parameters: parameters, headers: headers)
                .validate(statusCode: 200..<299)
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        guard let value = response.value as? [String: Any] else {
                          print("Error \(String(describing: response.error))")
                          // completion error
                          return
                        }
                        if let value = value["data"]  {
                            let json = JSON(value)
                            observer.on(.next(json))
                        }
                        
                    case.failure(let error):
                        observer.on(.error(error))
                    }
                    observer.on(.completed)
            }
            return Disposables.create()
        }
    }
    
    func getImage(url: String) throws -> Observable<Data>   {
        return Observable<Data>.create { (observer) -> Disposable in
            AF.request(url)
                .validate(statusCode: 200..<299)
                .response { response in
                    if let error = response.error {
                        observer.on(.error(error))
                    } else  if let data = response.data {
                        observer.on(.next(data))
                    }
                    observer.on(.completed)
            }
            return Disposables.create()
        }
    }

}

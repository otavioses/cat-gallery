//
//  CollectionViewPresenter.swift
//  cat-gallery
//
//  Created by Otávio Souza on 11/08/20.
//  Copyright © 2020 otavioses. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol CollectionViewPresenterProtocol {
    func loadCatImages()
}

class CollectionViewPresenter: NSObject {
    
    private var collectionViewProcotol: CollectionViewProtocol
    var connectionControll = 0.0
    var countReturn = 0
    
    init(view: CollectionViewProtocol) {
        self.collectionViewProcotol = view
    }
    
    func parseCatList(json: JSON)  {
        
        var list = Array<Cat>()
        if let values = json.array {
            for value in values {
                let images = value["images"].arrayValue
                for image in images {
                    let cat = Cat(json: image)
                    list.append(cat)
                    getImage(cat: cat, list: list)
                }
            }
        }
        if !list.isEmpty {
            collectionViewProcotol.update(catList: list)
        }
        
    }
    private func getImage(cat: Cat, list: Array<Cat>) {
        connectionControll += 1
        print("connectionControll - \(connectionControll)")
        Timer.scheduledTimer(withTimeInterval: connectionControll * 0.3, repeats: false) { (timer) in
            do {
                _ = try ConnectionManager().getImage(url: cat.link).subscribe { event in
                    switch event {
                    case .next(let result):
                        if let image = UIImage(data: result) {
                            cat.image = image
                            self.countReturn += 1
                            print("countReturn - \(self.countReturn)")
                            self.collectionViewProcotol.reloadCollectionView()
                        }
                    case .error(let error):
                        print("error \(error.localizedDescription)")
                    case .completed: break
                    }
                }
            } catch {
            }
        }
    }
}

extension CollectionViewPresenter: CollectionViewPresenterProtocol {
    func loadCatImages() {
        do {
            _ = try ConnectionManager().getList(of: "cats").subscribe { event in
                switch event {
                case .next(let result):
                    self.parseCatList(json: result)
                    
                case .error(let error):
                    print("error \(error.localizedDescription)")
                case .completed: break
                }
            }
        } catch {
        }
    }
}

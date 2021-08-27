//
//  AppContext.swift
//  MovieBrowser
//
//  Created by Admin on 8/20/21.
//  Copyright © 2021 Lowe's Home Improvement. All rights reserved.
//

import UIKit

enum AppContextConstant: String, CaseIterable {
    case title = "title"
    case releaseDate = "releaseDate"
    case overview = "overview"
    case posterURL = "posterURL"
}

public class AppContext {
    
    static let sharedInstance: AppContext = {
        let instance = AppContext()

        return instance
    }()
    
    fileprivate var persistence = PersistenceHandler()
    
    func setAppContextValue(value: Any?,forKey key: AppContextConstant){
        persistence.setValue(value, forKey: key.rawValue, in: self)
    }
    
    func getValue<T>(forKey key: AppContextConstant, as type: T.Type = T.self) -> T? {
        persistence.getValue(forKey: key.rawValue, in: self)
    }
}

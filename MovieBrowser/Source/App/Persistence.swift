//
//  Persistence.swift
//  MovieBrowser
//
//  Created by Admin on 8/20/21.
//  Copyright © 2021 Lowe's Home Improvement. All rights reserved.
//

import UIKit
public protocol Persistence {
    func setValue(_ value: Any?, forKey key:String, in component: AnyObject)
    func getValue<T>(forKey key: String, in component: AnyObject) -> T?
}

class PersistenceHandler {
    var data = [String: Any]()
}

extension PersistenceHandler: Persistence {
    private func keyValue(forKey key: String, in component: AnyObject) -> String {
        let bundle = Bundle(for: type(of: component))
        return bundle.bundleURL.lastPathComponent + "_" + key
    }
    
    func setValue(_ value: Any?, forKey key: String, in component: AnyObject) {
        let componentNameWithKwy = keyValue(forKey: key, in: component)
        if let value = value {
            self.data[componentNameWithKwy] = value
        } else {
            self.data.removeValue(forKey: componentNameWithKwy)
        }
    }
    
    func getValue<T>(forKey key: String, in component: AnyObject) -> T? {
        let componentNameWithKwy = keyValue(forKey: key, in: component)
        return self.data[componentNameWithKwy] as? T
    }
}

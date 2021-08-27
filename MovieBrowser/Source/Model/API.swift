//
//  API.swift
//  MovieBrowser
//
//  Created by Shahjahanian, Vartan on 8/19/21.
//  Copyright © 2021 Lowe's Home Improvement. All rights reserved.
//

import UIKit
enum API {
    enum ThemoviedbAPI {
        static let apiKey = "5885c445eab51c7004916b9c0313e2d3"
        static let baseURL = "https://api.themoviedb.org"
        static let imageBaseURL = "https://image.tmdb.org/t/p/original"
        enum Methods {
            static let search = "search"
        }
        enum DataSource {
            static let movie = "movie"
        }
        enum Version {
            static let three = "3"
        }
    }
}

enum HTTPMethod: String, Encodable {
    case GET
}





//
//  SearchMovieModels.swift
//  MovieBrowser
//
//  Created by Shahjahanian, Vartan on 8/19/21.
//  Copyright © 2021 Lowe's Home Improvement. All rights reserved.
//

import Foundation


//MARK:- Search Movie Request string parameters
struct SearchMovieParameters {
    let apiKey: String
    let query: String
    let language: String?
    let page: Int?
    let include_adult: Bool?
    let region: String?
    let year: Int?
    let primary_release_year: Int?
    
    // creating URL String Parameters
    mutating func getURLStringParamertrs() -> String {
        var paramertrs = "api_key=" + self.apiKey
        let quer = self.query.replacingOccurrences(of: " ", with: "%20")
        paramertrs += "&query=" + quer
        if let language = self.language {
            paramertrs += "&language=" + language
        }
        if let page = self.page {
            paramertrs += "&page=" + String(page)
        }
        if let include_adult = self.include_adult {
            paramertrs += "&include_adult=" + String(include_adult)
        }
        if let region = self.region {
            paramertrs += "&region=" + region
        }
        if let primary_release_year = self.primary_release_year {
            paramertrs += "&primary_release_year=" + String(primary_release_year)
        }
        return paramertrs
    }
}

fileprivate struct _SearchMovieRequest {
    //creating URL String
    mutating func getURLString() -> String {
        let baseURL: String = API.ThemoviedbAPI.baseURL
        let method: String = API.ThemoviedbAPI.Methods.search
        let source: String = API.ThemoviedbAPI.DataSource.movie
        let version: String = API.ThemoviedbAPI.Version.three
        return "\(baseURL)/\(version)/\(method)/\(source)"
    }
    //returning API key
    mutating func getAPI_KEY() -> String {
        return API.ThemoviedbAPI.apiKey
    }
}
//MARK: - Search movie request
struct SearchMovieRequest {
    private(set) public var url: URL?
    
    init(query: String,
         language: String?,
         page: Int?,
         year: Int?,
         include_adult: Bool?,
         primary_release_year: Int?,
         region: String?)
    {
        var request = _SearchMovieRequest()
        var urlString = request.getURLString()
        let apiKey = request.getAPI_KEY()
        var rquestParamerters = SearchMovieParameters(apiKey: apiKey, query: query, language: language, page: page, include_adult: include_adult, region: region, year: year, primary_release_year: primary_release_year)
        let par = rquestParamerters.getURLStringParamertrs()
        urlString += "?" + par
        self.url = URL(string: urlString)
    }
}

// MARK: - Search move response
struct SearchMovieResponse: Decodable {
    let page: Int
    let results: [Item]?
    let totalPages, totalResults: Int?

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

// MARK: - Item
struct Item: Decodable {
    let adult: Bool?
    let backdropPath: String?
    let genreIDS: [Int]?
    let id: Int?
    let originalLanguage: String?
    let originalTitle, overview: String?
    let popularity: Double?
    let posterPath, releaseDate, title: String?
    let video: Bool?
    let voteAverage: Double?
    let voteCount: Int?

    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case genreIDS = "genre_ids"
        case id
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview, popularity
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case title, video
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}



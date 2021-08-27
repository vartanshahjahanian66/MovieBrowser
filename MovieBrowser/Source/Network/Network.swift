//
//  Network.swift
//  SampleApp
//
//  Created by Struzinski, Mark - Mark on 9/17/20.
//  Copyright © 2020 Lowe's Home Improvement. All rights reserved.
//  Modifyed By Shahjahanian, Vartan - on 20/8/21

import UIKit

enum AppErrorList: Error {
    case BadResponse
    case NoData
    case BadURL
    case NoConnection
}

protocol Networking {
    func fetchSearchMovie(query: String,
                          language: String?,
                          page: Int?,
                          year: Int?,
                          include_adult: Bool?,
                          primary_release_year: Int?,
                          region: String?,
                          _ completion: @escaping (Result<SearchMovieResponse, Error>) -> Void)
    
    func fetchImage(urlString : String,_ completion: @escaping (Result<Data, Error>) -> Void)
}


class Network: Networking {
    let session = URLSession(configuration: .default)
    let decoder = JSONDecoder()
    
    func fetchSearchMovie(query: String,
                     language: String?,
                     page: Int?,
                     year: Int?,
                     include_adult: Bool?,
                     primary_release_year: Int?,
                     region: String?,
                     _ completion: @escaping (Result<SearchMovieResponse, Error>) -> Void)
    {
        let request = SearchMovieRequest(query: query, language: language, page: page, year: year, include_adult: include_adult, primary_release_year: primary_release_year, region: region)
        guard let url = request.url else {
            // TODO: - some error here, or better: write this differently
            return
        }
        let task = session.dataTask(with: url) { [weak self] (data, response, error) in
            if let error = error {
                completion(.failure(error as NSError)); return
            }
            if let response = response {
                // do something here if it's not 200..<400
            }
            guard let data = data else {
                // something about no data here
                return
            }
            do {
                if let responseData = try self?.decoder.decode(SearchMovieResponse.self, from: data) {
                    completion(.success(responseData))
                }
            } catch {
                completion(.failure(error as NSError))
            }
        }
        task.resume()
    }
    
    func fetchImage(urlString : String,_ completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            // TODO: - some error here, or better: write this differently
            return
        }
        let task = session.dataTask(with: url) {(data, response, error) in
            if let error = error {
                completion(.failure(error as NSError)); return
            }
            if let response = response {
                // do something here if it's not 200..<400
            }
            guard let data = data else {
                // something about no data here
                return
            }
            completion(.success(data))
        }
        task.resume()
    }
}

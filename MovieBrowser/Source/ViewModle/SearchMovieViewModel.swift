//
//  SearchMovieViewModel.swift
//  MovieBrowser
//
//  Created by Shahjahanian, Vartan on 8/20/21.
//  Copyright © 2021 Lowe's Home Improvement. All rights reserved.
//
import UIKit

class SearchMovieViewModel {
    private var service: Networking
    private(set) var pageNumber: Int = 1
    private(set) var isLoading: Bool = false
    private var updateHandler: (() -> Void)?
    init(){
        self.service = Network()
    }
    private var movieTtems: [Item]? {
        didSet {
            self.updateHandler?()
        }
    }
}

extension SearchMovieViewModel {
    fileprivate func setNetworkService(networkService:Networking) {
        self.service = networkService
    }
    
    var numberOfRows: Int {
        guard let count = movieTtems?.count else {return 0}
        return count
    }
    
    func removeAll() {
        movieTtems?.removeAll()
        //self.updateHandler?()
    }

    func getMovieTitle(for index: Int) -> String {
        guard let result = movieTtems?[index].title else {return ""}
        return result
    }
    
    func getVoteAverage(for index: Int) -> String {
        guard let result = movieTtems?[index].voteAverage else {return ""}
        return String(result)
    }
    
    func getReleaseDate(for index: Int) -> String {
        guard let result = movieTtems?[index].releaseDate else {return ""}
        return result
    }
    
    func getOverview(for index: Int) -> String {
        guard let result = movieTtems?[index].overview else {return ""}
        return result
    }
    
    func getPosterURL(for index: Int) -> String {
        guard let result = movieTtems?[index].posterPath else {return ""}
        return result
    }
    
    func bind(_ updateHandler: @escaping () -> Void) {
        self.updateHandler = updateHandler
    }

    func unbind() {
        self.updateHandler = nil
    }
    
    func fetchSearchMovie(query: String, language: String? = nil, page: Int? = nil, year: Int? = nil, include_adult: Bool? = nil, primary_release_year: Int? = nil, region: String? = nil, _ completion: @escaping (Error?) -> Void)
    {
        service.fetchSearchMovie(query: query, language: language, page: self.pageNumber, year: year, include_adult: include_adult, primary_release_year: primary_release_year, region: region) { (result) in
            switch result {
            case .success(let SearchMvies):
                if var items = self.movieTtems {
                    if let results = SearchMvies.results {
                        items.append(contentsOf: results)
                        self.movieTtems = items
                    }
                    
                } else {
                    self.movieTtems = SearchMvies.results
                }
                completion(nil)
            case .failure(let err):
                completion(err)
                print(err)
            }
        }
    }
    
    func loadMoreData(query: String, language: String? = nil, page: Int? = nil, year: Int? = nil, include_adult: Bool? = nil, primary_release_year: Int? = nil, region: String? = nil, _ completion: @escaping (Error?) -> Void)
    {
        DispatchQueue.main.async {
            self.pageNumber += 1
            self.isLoading = true
        }
        self.fetchSearchMovie(query: query){ err in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            guard let err = err else {
                return
            }
            completion(err)
        }
    }
}

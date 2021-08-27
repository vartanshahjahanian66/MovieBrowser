//
//  MovieDetailViewModle.swift
//  MovieBrowser
//
//  Created by Shahjahanian, Vartan on 8/21/21.
//  Copyright © 2021 Lowe's Home Improvement. All rights reserved.
//

import Foundation
import UIKit
class DetailViewModel {
    private var movieDetail: MovieDetailModle {
        didSet {
            self.updateHandler?()
        }
    }
    private var service: Networking
    private var updateHandler: (() -> Void)?
    private var appContext = AppContext.sharedInstance
    init(){
        self.service = Network()
        self.movieDetail = MovieDetailModle()
    }
}

extension DetailViewModel {
    
    func getMovieTitle() -> String {
        guard let result = self.appContext.getValue(forKey: .title, as: String.self) else {return ""}
        return result
    }
    
    func getReleaseDate() -> String {
        guard let result = self.appContext.getValue(forKey: .releaseDate, as: String.self) else {return ""}
        return result
    }
    
    func getOverview() -> String {
        guard let result = self.appContext.getValue(forKey: .overview, as: String.self) else {return ""}
        return result
    }
    
    func getPosterURL() -> String {
        guard let result = self.appContext.getValue(forKey: .posterURL, as: String.self) else {return ""}
        return result
    }
    
    func getPosterImage() -> UIImage? {
        guard let result = self.movieDetail.posterImage else {return nil}
        return result
    }
    
    func bind(_ updateHandler: @escaping () -> Void) {
           self.updateHandler = updateHandler
    }
       
    func unbind() {
       self.updateHandler = nil
    }
    
    func getURLString(urlString: String) -> String {
        let baseURL: String = API.ThemoviedbAPI.imageBaseURL
        return "\(baseURL)/\(urlString)"
    }
    
    func fetchPosterImage(urlString:String,_ completion: @escaping (Error?) -> Void)  {
        let imageURLString = self.getURLString(urlString: urlString)
        service.fetchImage(urlString: imageURLString) { (result) in
            switch result {
                case .success(let image):
                    self.movieDetail.posterImage = UIImage(data: image)
                    completion(nil)
                case .failure(let err):
                    self.movieDetail.posterImage = nil
                    completion(err)
                    print(err)
            }
        }
    }
}


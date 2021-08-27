//
//  MovieDetailViewController.swift
//  SampleApp
//
//  Created by Struzinski, Mark on 2/26/21.
//  Copyright © 2021 Lowe's Home Improvement. All rights reserved.
//
//  Modifyed By Shahjahanian, Vartan - on 20/8/21

import UIKit

class MovieDetailViewController: UIViewController {
    @IBOutlet weak var movieImageView : UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var overview: UITextView!
    @IBOutlet weak var releasDate: UILabel!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    private let viewModel = DetailViewModel()
    private var actInd = UIActivityIndicatorView()
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
        self.viewModel.bind {
            DispatchQueue.main.async {
                self.updateUI()
            }
        }
        self.activityIndicator(true)
        self.viewModel.fetchPosterImage(urlString: self.viewModel.getPosterURL()){ [weak self] err in
            guard err != nil else {
                self?.activityIndicator(false)
                return
            }
            self?.activityIndicator(false)
            self?.alert(err: err as? AppErrorList)
        }
    }
    
    private func activityIndicator(_ status: Bool){
        if status {
            self.actInd.startAnimating()
        } else {
            DispatchQueue.main.async {
                self.actInd.stopAnimating()
            }
        }
    }
    
    func setupUI(){
        self.overview.textContainerInset = UIEdgeInsets.zero
        // Activity IndicatorView
        self.setupActivityIndicatorView()
        //navigation
        self.setupNavigation()
    }
    
    func setupActivityIndicatorView(){
        self.actInd.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
        self.actInd.center = self.movieImageView.center
        self.actInd.hidesWhenStopped = true
        self.actInd.style = UIActivityIndicatorView.Style.large
    }
    
    func setupNavigation(){
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = "Movie Detail"
    }

    func updateUI(){
        self.movieTitle.text = viewModel.getMovieTitle()
        self.overview.text =  viewModel.getOverview()
        let newDateString = formatDateString(self.viewModel.getReleaseDate())
        self.releasDate.text = newDateString
        
        if let image = viewModel.getPosterImage() {
            let newSize = self.calculateImageViewHeight(size:image.size)
            self.imageHeight.constant = newSize.height
            self.imageWidth.constant = newSize.width
            self.movieImageView.image = image
        }
    }
    
    func formatDateString(_ dateString: String?) -> String {
        guard let dateString = dateString else {
            return ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from:dateString) {
            let df = DateFormatter()
            df.dateFormat = "MM/d/yyyy"
            return df.string(from: date)
        }
        return ""
    }
    
    func calculateImageViewHeight(size: CGSize) -> CGSize {
        var result = CGSize()
        let ratio = size.width / size.height
        if size.width > size.height {
            let newHeight = self.movieImageView.frame.width * ratio
            result = CGSize(width: self.movieImageView.frame.width, height: newHeight)
        }
        else{
            let newHeight = self.movieImageView.frame.width / ratio
            result = CGSize(width: self.movieImageView.frame.width, height: newHeight)
        }
        return result
    }

    func alert(err:AppErrorList?) {
        var alertString = ""
        guard let err = err else {
            return
        }
        switch err {
        case .BadResponse:
            alertString = "Response is not valid"
        case .BadURL:
            alertString = "URL is not valid"
        case .NoData:
            alertString = "Data does not exist"
        case .NoConnection:
            alertString = "No internet connection"
        }
        DispatchQueue.main.async() {
            let alert = UIAlertController(title: "error", message: alertString, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}



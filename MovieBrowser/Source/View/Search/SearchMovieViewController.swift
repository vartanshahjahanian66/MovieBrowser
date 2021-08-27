//
//  SearchMovieViewController.swift
//  SampleApp
//
//  Created by Struzinski, Mark on 2/19/21.
//  Copyright © 2021 Lowe's Home Improvement. All rights reserved.
//
//  Modifyed By Shahjahanian, Vartan - on 20/8/21

import UIKit

class SearchMovieViewController: UIViewController {
    enum Constants {
        static let cellReuseId = "MovieTableViewCell"
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var goButton: UIButton!
    
    private var appContext = AppContext.sharedInstance
    let viewModel = SearchMovieViewModel()
    //let searchController = UISearchController(searchResultsController: nil)
    var actInd = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.viewModel.bind {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func setupUI(){

        self.searchBar.delegate = self
        // Activity IndicatorView
        self.setupActivityIndicatorView()
        //tableview
        self.setupTableView()
        //navigation
        self.setupNavigation()
    }
    
    
    
    func setupActivityIndicatorView(){
        self.actInd.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
        self.actInd.center = self.tableView.center
        self.actInd.hidesWhenStopped = true
        self.actInd.style = UIActivityIndicatorView.Style.large
    }
    
    func setupTableView(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundView = self.actInd
    }
    
    func setupNavigation(){
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = "Movie Search"
    }
    
    @IBAction func goButtonTap(_ sender: Any) {
        guard let text = self.searchBar.text  else {
            return
        }
        if text == "" {
            return
        }
        self.viewModel.removeAll()
        self.activityIndicator(true)
        self.viewModel.fetchSearchMovie(query: text){ [weak self] err in
            guard let err = err else {
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

extension SearchMovieViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.viewModel.removeAll()
        }
    }
}

extension SearchMovieViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseId, for: indexPath) as? MovieTableViewCell else {
            fatalError("Could not dequeue cell, please register first")
        }
        let newDateString = formatDateString(self.viewModel.getReleaseDate(for: indexPath.row))
        cell.releaseDate.text = newDateString
        cell.voteAverage.text = self.viewModel.getVoteAverage(for: indexPath.row)
        cell.movieTitle.text = self.viewModel.getMovieTitle(for: indexPath.row)
        cell.backgroundColor = .white
        return cell
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
            df.dateFormat = "MMM d, yyyy"
            return df.string(from: date)
        }
        return ""
    }
}

extension SearchMovieViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard (tableView.cellForRow(at: indexPath) as? MovieTableViewCell) != nil
        else {
           fatalError("Could not dequeue cell, please register first")
        }
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        let proVC = storyBoard.instantiateViewController(identifier: "MovieDetailViewController") as MovieDetailViewController
        self.saveContext(indexPath: indexPath)
        self.navigationController?.pushViewController(proVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let text = self.searchBar.text  else {
            return
        }
        let lastElement = self.viewModel.numberOfRows - 1
        print(lastElement)
        print(indexPath.row)
        print(self.viewModel.isLoading)
        if !self.viewModel.isLoading && indexPath.row == lastElement {
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))

            tableView.tableFooterView = spinner
            tableView.tableFooterView?.isHidden = false
            self.viewModel.loadMoreData(query: text){ [weak self] err in
                DispatchQueue.main.async {
                    tableView.tableFooterView?.isHidden = true
                    spinner.stopAnimating()
                }
            }
        }
    }
    
    private func saveContext(indexPath: IndexPath) {
        self.appContext.setAppContextValue(value: self.viewModel.getReleaseDate(for: indexPath.row), forKey: .releaseDate)
        self.appContext.setAppContextValue(value: self.viewModel.getMovieTitle(for: indexPath.row), forKey: .title)
        self.appContext.setAppContextValue(value: self.viewModel.getOverview(for: indexPath.row), forKey: .overview)
        self.appContext.setAppContextValue(value: self.viewModel.getPosterURL(for: indexPath.row), forKey: .posterURL)
    }
}

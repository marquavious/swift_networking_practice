//
//  ViewController.swift
//  networking_test
//
//  Created by Marquavious on 6/9/17.
//  Copyright © 2017 Marquavious Draggon. All rights reserved.
//

import UIKit

typealias JSON = [String:Any]

class ViewController: UITableViewController {
    
    var movieArray = [Movie]()
    let refresher = UIRefreshControl()
    let activityIndicator  = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createRefresher()
        setUpTopLeftButton()
        setUpTopRightButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        grabMovies()
        DataManager.sharedInstance.checkDateToUpdateJSON(10)
    }
    
    func setUpTopLeftButton(){
        let barButton = UIBarButtonItem(customView: activityIndicator)
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.hidesWhenStopped = true
        navigationItem.setLeftBarButton(barButton, animated: true)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        navigationItem.leftBarButtonItem?.customView = activityIndicator
    }
    
    func setUpTopRightButton(){
        let btn1 = UIButton(type: .system)
        btn1.setTitle("Clear Cashe", for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        btn1.addTarget(self, action: #selector(clearCashe), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        self.navigationItem.setRightBarButtonItems([item1], animated: true)
    }
    
    func createRefresher(){
        refresher.addTarget(self, action: #selector(grabMovies), for: .valueChanged)
//        refresher.attributedTitle = NSAttributedString(string: returnLastDateUpdated())
        refresher.backgroundColor = .white
        tableView.addSubview(refresher)
    }
    
    func clearCashe(){
        DataManager.sharedInstance.clearUserDefaults()
        movieArray = []
        tableView.reloadData()
    }
    
    func grabMovies(){
        self.activityIndicator.startAnimating()
        DataManager.sharedInstance.returnMovies {(movies, error, source) in
            if error != nil{
                let alert = UIAlertController(title: "Error", message: "Couldnt connect to the server. Please check your internet connection.", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion:nil)
                
                self.refreshRefresher()
                return
            }
            
            self.movieArray = movies
            self.refreshRefresher()
            
        }
    }
    
    func refreshRefresher(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
            if self.activityIndicator.isAnimating{
                self.activityIndicator.stopAnimating()
            }
            if (self.refresher.isRefreshing) {
                self.refresher.endRefreshing()
            }
//            self.refresher.attributedTitle = NSAttributedString(string: (self.returnLastDateUpdated()))
        }
    }
    
    func returnLastDateUpdated() -> String {
        guard let time = UserDefaults.standard.object(forKey: "information_last_updated") else {
            return "Movies not updated :("
        }
        
        let string = "Movies were last updated \(DateHelper.dateToString(date: time as! Date))"
        return string
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Last Time Updated", message: self.returnLastDateUpdated(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion:nil)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = movieArray[indexPath.row].title
        cell.backgroundColor = .white
        cell.selectionStyle = .none
        return cell
    }
}

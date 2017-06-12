//
//  ViewController.swift
//  networking_test
//
//  Created by Marquavious on 6/9/17.
//  Copyright © 2017 Marquavious Draggon. All rights reserved.
//

import UIKit

typealias JSON = [String:Any]
var refresher: UIRefreshControl!

class ViewController: UITableViewController {
    
    var movieArray = [Movie]()
    let parser = ItunesJSONParser()
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        grabMovies()
        createActivitySpinner()
        showPrompt()
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: self.returnLastDateUpdated())
        tableView.insertSubview(refresher, at: 0)
        refresher.addTarget(self, action: #selector(updateButtonPressed), for: .valueChanged)
    }
    
//    func setUpTopRightButton(){
//        let btn1 = UIButton(type: .system)
//        btn1.setTitle("Update", for: .normal)
//        btn1.frame = CGRect(x: 0, y: 0, width: 75, height: 30)
//        btn1.addTarget(self, action: #selector(updateButtonPressed), for: .touchUpInside)
//        let item1 = UIBarButtonItem(customView: btn1)
//        self.navigationItem.setRightBarButtonItems([item1], animated: true)
//    }
    
    func showPrompt(){
        showLastUpdatedPrompt {
            self.removeUpdatedPromp()
        }
    }
    
    func removeUpdatedPromp(){
        let delayInSeconds = 4.0
        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) { // 2
            self.navigationItem.prompt = nil
        }
    }
    
    func showLastUpdatedPrompt(completion:@escaping () -> ()){
        //        activityIndicator.isHidden = true
        let delayInSeconds = 3.0 // 1
        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) { // 2
            self.navigationItem.prompt = self.returnLastDateUpdated()
            refresher.endRefreshing()
            completion()
        }
    }
    
    func updateButtonPressed() {
        self.activityIndicator.startAnimating()
        refresher.attributedTitle = NSAttributedString(string: "Updating Movies...")
        DataSource.sharedInstance.updateUserDefaults { (error) in
            if error == .failure{
                DispatchQueue.global(qos: .userInitiated).async {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                        self.refreshControl?.endRefreshing()
                    }
                }
                
                let alert = UIAlertController(title: "Error", message: "Couldnt connect to the server. Please check your internet connection.", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: {
                    return
                })
            }
            
            self.activityIndicator.stopAnimating()
            self.showPrompt()
            self.grabMovies()
            refresher.attributedTitle = NSAttributedString(string: self.returnLastDateUpdated())
        }
    }
    
    func createActivitySpinner(){
        let barButton = UIBarButtonItem(customView: activityIndicator)
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.hidesWhenStopped = true
        navigationItem.setLeftBarButton(barButton, animated: true)
    }
    
    func grabMovies(){
        self.activityIndicator.startAnimating()
        DataSource.sharedInstance.returnMovies {(movies, error) in
            
            if error == .failure{
                DispatchQueue.global(qos: .userInitiated).async {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                        self.refreshControl?.endRefreshing()
                    }
                }
                
                let alert = UIAlertController(title: "Error", message: "Couldnt connect to the server. Please check your internet connection.", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: {
                    
                    return
                })
            }
            self.movieArray = movies
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.refreshControl?.endRefreshing()

        }
        self.tableView.reloadData()
    }
    
    func returnLastDateUpdated() -> String {

        if tableView.numberOfRows(inSection: 0) < 1{
            return "Movies were never updated :("
        }
    
        let time = (UserDefaults.standard.object(forKey: "information_last_updated")!)
        let string = "Movies were last updated \(DateHelper.dateToString(date: time as! Date))"
        return string
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = movieArray[indexPath.row].title
        return cell
    }
}


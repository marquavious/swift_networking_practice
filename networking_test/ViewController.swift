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
    let parser = ItunesJSONParser()
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        grabMovies()
        createActivitySpinner()
        setUpTopRightButton()
        showPrompt()
    }
    
    func setUpTopRightButton(){
        let btn1 = UIButton(type: .system)
        btn1.setTitle("Update", for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 75, height: 30)
        btn1.addTarget(self, action: #selector(updateButtonPressed), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        self.navigationItem.setRightBarButtonItems([item1], animated: true)
    }
    
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
        let delayInSeconds = 3.0 // 1
        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) { // 2
            let time = (UserDefaults.standard.object(forKey: "information_last_updated")!)
            let string = "Movies were last updated \(DateHelper.dateToString(date: time as! Date))"
            self.navigationItem.prompt = string
            completion()
        }
    }
    
    func updateButtonPressed() {
        self.activityIndicator.startAnimating()
        self.navigationItem.prompt = "Updating..."
        DataSource.sharedInstance.updateUserDefaults {
            self.activityIndicator.stopAnimating()
            self.showPrompt()
            self.grabMovies()
        }
    }
    
    func createActivitySpinner(){
        let barButton = UIBarButtonItem(customView: activityIndicator)
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.hidesWhenStopped = true
        navigationItem.setLeftBarButton(barButton, animated: true)
    }
    
    func grabMovies(){
        DataSource.sharedInstance.returnMovies {(movies) in
            self.activityIndicator.startAnimating()
            self.movieArray = movies
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
        }
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


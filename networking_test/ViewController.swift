//
//  ViewController.swift
//  networking_test
//
//  Created by Marquavious on 6/9/17.
//  Copyright © 2017 Marquavious Draggon. All rights reserved.
//

import UIKit

typealias JSON = [String:Any]

class ViewController: UIViewController {
    
    let parser = ItunesJSONParser()
    var movieArray = [Movie]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        grabMovies()
    }
    
    func grabMovies(){
        DataSource.sharedInstance.returnMovies { (movies) in
            self.movieArray = movies
        }
    }
}


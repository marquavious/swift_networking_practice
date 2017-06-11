//
//  DataSource.swift
//  networking_test
//
//  Created by Marquavious on 6/9/17.
//  Copyright © 2017 Marquavious Draggon. All rights reserved.
//

import UIKit

typealias MovieDictionaryFormat = [String:[String:String]]

enum UserDefautPaths:String{
    case movieTitle = "movieTitle"
    case moviePhotoUrl = "moviePhotoUrl"
}

class DataSource {
    
    static let sharedInstance = DataSource()
    
    var itunesJSONParser = ItunesJSONParser()
    
    // Fetch song from database and save it in NSUserdefaults
    func grabInformationAndSaveItToUserDefaults(completion: @escaping () -> ()){
        itunesJSONParser.createAndReturnMovieObjects { (movies, error) in
            var movieDictionary = MovieDictionaryFormat()
            for movieObject in movies {
                movieDictionary[movieObject.title] = ["movieTitle":movieObject.title,"moviePhotoUrl":movieObject.photoUrl]
            }
            let date = Date()
            UserDefaults.standard.set(movieDictionary, forKey: "movie_dictionary")
            UserDefaults.standard.set(date, forKey: "information_last_updated")
            UserDefaults.standard.synchronize()
            completion()
        }
    }
    
    // Chech time for update "Updates every 5 minutes"
    func checkDateToUpdateJSON(_ time:Double){
        DispatchQueue.global(qos:.background).async {
            let date = Date()
            let lastUpdatedDate = UserDefaults.standard.object(forKey: "information_last_updated") as! Date
            let pastTime = date.timeIntervalSince(lastUpdatedDate)/60
            if pastTime > time {
                self.updateUserDefaults(completion: {
                })
            }
        }
    }
    
    // Return movies from NSUSER Defaults
    func grabInformationFromUserDefaults() -> Any {
        return UserDefaults.standard.value(forKey: "movie_dictionary")!
    }
    
    // Check to see if movies are in NSUser Defaults
    func isMoviesInUserDefaults() -> Bool {
        if UserDefaults.standard.value(forKey: "movie_dictionary") != nil{
            return true
        }
        return false
    }
    
    // Update UserDefauts
    func updateUserDefaults(completion: @escaping () -> ()){
//        UserDefaults.standard.removeObject(forKey: "movie_dictionary")
        grabInformationAndSaveItToUserDefaults {
            completion()
        }
    }
    
    // Return array of movies
    func returnMovies(completion: @escaping ([Movie]) -> ()){
        if isMoviesInUserDefaults(){
            let moveisAnyObject = grabInformationFromUserDefaults() as! MovieDictionaryFormat
            convertMoviesFromDictionaryToMovieObjects(moviesJson: moveisAnyObject, completion: { (movies) in
                completion(movies)
            })
        } else {
            itunesJSONParser.createAndReturnMovieObjects(completion: { (movies, result) in
                
            })
        }
    }
    
    // Converts from MovieDictionaryFormat to Movie Objects
    private func convertMoviesFromDictionaryToMovieObjects(moviesJson:MovieDictionaryFormat,completion: @escaping ([Movie]) -> ()){
        var arrayOfMovies = [Movie]()
        for movie in moviesJson {
            let movieObject = Movie()
            movieObject.title = movie.value["movieTitle"]!
            movieObject.photoUrl = movie.value["moviePhotoUrl"]!
            arrayOfMovies.append(movieObject)
        }
        completion(arrayOfMovies)
    }
}










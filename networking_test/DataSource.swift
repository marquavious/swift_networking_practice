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
    func grabInformationAndSaveItToUserDefaults(completion: @escaping (ItunesJSONParser.ParseResult) -> ()){
        itunesJSONParser.createAndReturnMovieObjects { (movies, error) in
            if error == .failure{
                completion(.failure)
            }
            
            var movieDictionary = MovieDictionaryFormat()
            for movieObject in movies {
                movieDictionary[movieObject.title] = ["movieTitle":movieObject.title,"moviePhotoUrl":movieObject.photoUrl]
            }
            UserDefaults.standard.set(movieDictionary, forKey: "movie_dictionary")
            UserDefaults.standard.set(Date(), forKey: "information_last_updated")
            UserDefaults.standard.synchronize()
            completion(.sucessful)
        }
    }
    
    // Chech time for update "Updates every 5 minutes"
    func checkDateToUpdateJSON(_ time:Double){
        DispatchQueue.global(qos:.background).async {
            let date = Date()
            let lastUpdatedDate = UserDefaults.standard.object(forKey: "information_last_updated")
            if lastUpdatedDate == nil {
                UserDefaults.standard.set(date, forKey: "information_last_updated")
                UserDefaults.standard.synchronize()
            }
            guard let lastUpdatedDateAsDate = UserDefaults.standard.object(forKey: "information_last_updated") as? Date else {return}
            let pastTime = date.timeIntervalSince(lastUpdatedDateAsDate)/60
            if pastTime > time {
                self.updateUserDefaults(completion: { (result) in
                    
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
        guard (UserDefaults.standard.value(forKey: "movie_dictionary") != nil) else {
            return false
        }
        let unwrappedMovies = UserDefaults.standard.value(forKey: "movie_dictionary") as! MovieDictionaryFormat
        if unwrappedMovies.count > 5 {
            return true
        }
        return false
    }
    
    // Update UserDefauts
    func updateUserDefaults(completion: @escaping (ItunesJSONParser.ParseResult) -> ()){
        grabInformationAndSaveItToUserDefaults {(error) in
            if error == .failure {
                completion(.failure)
            }
            completion(.sucessful)
        }
    }
    
    // Return array of movies
    func returnMovies(completion: @escaping ([Movie], ItunesJSONParser.ParseResult?) -> ()){
        if isMoviesInUserDefaults(){
            
            let moveisAnyObject = grabInformationFromUserDefaults() as! MovieDictionaryFormat
            
            convertMoviesFromDictionaryToMovieObjects(moviesJson: moveisAnyObject, completion: { (movies) in
                completion(movies, .sucessful)
            })
        } else {
            itunesJSONParser.createAndReturnMovieObjects(completion: { (movies, result) in
                if result == .failure {
                    completion(movies, .failure)
                }
                completion(movies, .sucessful)
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










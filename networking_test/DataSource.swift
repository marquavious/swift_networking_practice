//
//  DataSource.swift
//  networking_test
//
//  Created by Marquavious on 6/9/17.
//  Copyright © 2017 Marquavious Draggon. All rights reserved.
//

import UIKit

typealias MovieDictionaryFormat = [String:[String:Any]]

enum UserDefautPaths:String{
    case movieTitle = "movieTitle"
    case moviePhotoUrl = "moviePhotoUrl"
}

enum SourceOfMovies {
    case cashe
    case backend
}

class DataManager {
    
    static let sharedInstance = DataManager()
    
    // Fetch song from database and save it in NSUserdefaults
    func grabInformationAndSaveItToUserDefaults(completion: @escaping (Error?) -> ()){
        ItunesJSONParser.createAndReturnMovieObjects { (movies, error) in
            if error != nil {
                completion(error)
            }
            self.updateUserDefaults(movies: movies)
            completion(error)
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
    func grabInformationFromUserDefaults() -> MovieDictionaryFormat? {
        guard let moviesFromUserDefaults = UserDefaults.standard.value(forKey: "movie_dictionary") else {
            return nil
        }
        return moviesFromUserDefaults as? MovieDictionaryFormat
    }
    
    // Check to see if movies are in NSUser Defaults
    func isMoviesInUserDefaults() -> Bool {
        
        guard let unwrappedMovies = UserDefaults.standard.value(forKey: "movie_dictionary") as? MovieDictionaryFormat else {
            return false
        }
        
        if unwrappedMovies.count > 5 {
            return true
        }
        return false
    }
    
    // Update UserDefauts
    func updateUserDefaults(completion: @escaping (Error?) -> ()){
        grabInformationAndSaveItToUserDefaults {(error) in
            if error != nil {
                completion(error)
            }
            completion(error)
        }
    }
    
    // Clear user defaults
    func clearUserDefaults(){
        UserDefaults.standard.removeObject(forKey: "movie_dictionary")
        UserDefaults.standard.removeObject(forKey: "information_last_updated")
        UserDefaults.standard.synchronize()
    }
    
    //Update user defaults
    func updateUserDefaults(movies:[Movie]){
        
        var iterations:Int = 0
        var movieDictionary = MovieDictionaryFormat()
        for movieObject in movies {
            movieDictionary[movieObject.title] = ["movieTitle":movieObject.title,"moviePhotoUrl":movieObject.photoUrl,"entryNumber":iterations]
            iterations += 1
        }
        
        UserDefaults.standard.set(movieDictionary, forKey: "movie_dictionary")
        UserDefaults.standard.set(Date(), forKey: "information_last_updated")
        UserDefaults.standard.synchronize()
    }
    
    func sortMovies(movies:[Movie]) -> [Movie] {
        let sortedMovies = movies.sorted(){$0.entryNumber < $1.entryNumber}
        return sortedMovies
    }
    
    // Return array of movies
    func returnMovies(completion: @escaping ([Movie], Error?,SourceOfMovies) -> ()){
        if isMoviesInUserDefaults(){
            guard let moveisAnyObject = grabInformationFromUserDefaults() else {
                let error:Error = Error.self as! Error
                completion([], error, .cashe)
                return
            }
            convertMoviesFromDictionaryToMovieObjects(moviesJson: moveisAnyObject, completion: { (movies, error) in
                let sortedMovies = self.sortMovies(movies: movies)
                completion(sortedMovies, error, .cashe)
                
                self.updateUserDefaults(completion: {_ in })
            })
        } else {
            ItunesJSONParser.createAndReturnMovieObjects(completion: { (movies, error) in
                if error != nil {
                    completion([], error, .backend)
                }
                let sortedMovies = self.sortMovies(movies: movies)
                completion(sortedMovies, error,.backend)
            })
            updateUserDefaults(completion: {_ in })
        }
    }
    
    // Converts from MovieDictionaryFormat to Movie Objects
    private func convertMoviesFromDictionaryToMovieObjects(moviesJson:MovieDictionaryFormat,completion: @escaping ([Movie],Error?) -> ()){
        var arrayOfMovies = [Movie]()
        let error:Error? = nil
        for movie in moviesJson {
            let movieObject = Movie()
            
            guard let movieTitle = movie.value["movieTitle"] as? String else {
                completion([],error)
                return
            }
            guard let moviePhotoUrl = movie.value["moviePhotoUrl"] as? String else {
                completion([],error)
                return
            }
            guard let movieEntryNumber = movie.value["entryNumber"] as? Int else {
                completion([],error)
                return
            }
            
            movieObject.entryNumber = movieEntryNumber
            movieObject.title = movieTitle
            movieObject.photoUrl = moviePhotoUrl
            arrayOfMovies.append(movieObject)
        }
        completion(arrayOfMovies,error)
    }
}










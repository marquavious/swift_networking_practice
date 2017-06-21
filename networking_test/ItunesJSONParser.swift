//
//  ItunesJSONParser.swift
//  networking_test
//
//  Created by Marquavious on 6/9/17.
//  Copyright © 2017 Marquavious Draggon. All rights reserved.
//

import UIKit

struct ItunesJSONParser {
    
    static private func grabItunesData(completion: @escaping ([JSON],Error?) -> ()){
        let url = URL(string: "https://itunes.apple.com/us/rss/topvideorentals/limit=25/json")
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        let urlSession = URLSession(configuration: config)
        
        urlSession.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                error?.throwCustomError(function: #function)
                completion([],error)
                return
            }
            if let parsedData = try? JSONSerialization.jsonObject(with:data!) as! JSON {
                guard let feed = parsedData["feed"] as? JSON else {return}
                guard let entries = feed["entry"] as? [JSON] else {return}
                completion(entries,error)
            } else {
                completion([],error)
            }
            }.resume()
    }
    
    static private func returnName(json:JSON) -> String {
        // Probably not safe....
        let nameDictionary = json["im:name"] as? JSON
        let name = nameDictionary?["label"] as? String
        return name ?? "Error finding \"im:name\" in JSON"
    }
    
    static private func returnPhoto(json:JSON) -> String {
        // Probably not safe again :(
        let pictureDirectory = json["im:image"] as? [JSON]
        let photoUrl = pictureDirectory?[0]["label"] as? String
        return photoUrl ?? "Error finding \"im:image\" in JSON"
    }
    
    static func createAndReturnMovieObjects(completion: @escaping ([Movie],Error?) -> ()){
        var movieArray = [Movie]()
        var iterations:Int = 0
        grabItunesData { (json,error) in
            if error != nil {
                error?.throwCustomError(function: #function)
                completion([],error)
                return
            }
            for movieObject in json {
                let movie = Movie()
                movie.title = self.returnName(json: movieObject)
                movie.photoUrl = self.returnPhoto(json: movieObject)
                movie.entryNumber = iterations
                movieArray.append(movie)
                iterations += 1
            }
            completion(movieArray,error)
        }
    }
    
    //MARK: - USELESS FUNCTIONS
    
    static func createAndReturnMovieDictionary(completion: @escaping (MovieDictionaryFormat,Error?) -> ()){
        var movieDictionary = MovieDictionaryFormat()
        var iterations:Int = 0
        grabItunesData { (json,error) in
            if error != nil {
                error?.throwCustomError(function: #function)
                completion([:], error)
                return
            }
            for movieObject in json {
                let movie = Movie()
                movie.entryNumber = iterations
                movie.title = self.returnName(json: movieObject)
                movie.photoUrl = self.returnPhoto(json: movieObject)
                movieDictionary[movie.title] = ["movieTitle":movie.title,"photoUrl":movie.photoUrl,"entryNumber":iterations]
                iterations += 1
            }
            completion(movieDictionary, error)
        }
    }
    
    static func returnMovieNames(completion: @escaping ([String],Error?) -> ()){
        var stringArray = [String]()
        grabItunesData { (json, error) in
            if error != nil {
                error?.throwCustomError(function: #function)
                return
            }
            for movieObject in json {
                stringArray.append(self.returnName(json: movieObject))
            }
            completion(stringArray,error)
        }
    }
}


//
//  ItunesJSONParser.swift
//  networking_test
//
//  Created by Marquavious on 6/9/17.
//  Copyright © 2017 Marquavious Draggon. All rights reserved.
//

import UIKit

struct ItunesJSONParser {
    
    enum ParseResult: Error {
        case sucessful
        case failure
    }
    
    private func startParser(completion: @escaping ([JSON],ParseResult?) -> ()){
        let url = URL(string: "https://itunes.apple.com/us/rss/topmovies/limit=25/json")
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                error?.throwCustomError(function: #function)
                completion([], .failure)
                return
            }
            if let parsedData = try? JSONSerialization.jsonObject(with:data!) as! JSON {
                guard let feed = parsedData["feed"] as? JSON else {return}
                guard let entries = feed["entry"] as? [JSON] else {return}
                completion(entries, .sucessful) }
            }.resume()
    }
    
    private func returnName(json:JSON) -> String{
        // Probably not safe
        let nameDictionary = json["im:name"] as? JSON
        let name = nameDictionary?["label"] as? String
        return name ?? "Error finding \"im:name\" in JSON"
    }
    
    private func returnPhoto(json:JSON) -> String {
        // Probably not safe again
        let pictureDirectory = json["im:image"] as? [JSON]
        let photoUrl = pictureDirectory?[0]["label"] as? String
        return photoUrl ?? "Error finding \"im:image\" in JSON"
    }
    
    func returnMovieNames(completion: @escaping ([String],ParseResult?) -> ()){
        var stringArray = [String]()
        startParser { (json, error) in
            if error == .failure {
                error?.throwCustomError(function: #function)
                return
            }
            for movieObject in json {
                stringArray.append(self.returnName(json: movieObject))
            }
            completion(stringArray,.sucessful)
        }
    }
    
    func createAndReturnMovieObjects(completion: @escaping ([Movie],ParseResult?) -> ()){
        var movieArray = [Movie]()
        startParser { (json,error) in
            if error == .failure {
                error?.throwCustomError(function: #function)
                return
            }
            for movieObject in json {
                let movie = Movie()
                movie.title = self.returnName(json: movieObject)
                movie.photoUrl = self.returnPhoto(json: movieObject)
                movieArray.append(movie)
            }
            completion(movieArray, .sucessful)
        }
    }
    
    func createAndReturnMovieDictionary(completion: @escaping (MovieDictionaryFormat,ParseResult?) -> ()){
        var movieDictionary = MovieDictionaryFormat()
        startParser { (json,error) in
            if error == .failure {
                error?.throwCustomError(function: #function)
                return
            }
            for movieObject in json {
                let movie = Movie()
                movie.title = self.returnName(json: movieObject)
                movie.photoUrl = self.returnPhoto(json: movieObject)
                movieDictionary[movie.title] = ["movieTitle":movie.title,"photoUrl":movie.photoUrl]
            }
            completion(movieDictionary, .sucessful)
        }
    }
}


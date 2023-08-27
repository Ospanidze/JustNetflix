//
//  NetworkManager.swift
//  Just Netflix
//
//  Created by Айдар Оспанов on 24.08.2023.
//

import UIKit

struct Constant {
    static let apiKey = "2e347cb6d8489f80bf6bad945941c2a4"
    static let baseURL = "https://api.themoviedb.org"
    static let apiKeyYoutube = "AIzaSyBokrmUfzpmucFf5aJvIufU9qgPXBicAuo"
    static let baseYoutubeURL = "https://youtube.googleapis.com/youtube/v3/search?"
}

enum Link: Int {
    case movie = 0
    case tv
    case upcoming
    case popular
    case topRated
    case discovery
    
    var url: URL? {
        switch self {
        case .movie:
            return URL(string: "\(Constant.baseURL)/3/trending/movie/day?api_key=\(Constant.apiKey)")
        case .tv:
            return URL(string: "\(Constant.baseURL)/3/trending/tv/day?api_key=\(Constant.apiKey)")
        case .upcoming:
            return URL(string: "\(Constant.baseURL)/3/movie/upcoming?api_key=\(Constant.apiKey)&language=en-US&page=1")
        case .popular:
            return URL(string: "\(Constant.baseURL)/3/movie/popular?api_key=\(Constant.apiKey)&language=en-US&page=1")
        case .topRated:
            return URL(string: "\(Constant.baseURL)/3/movie/top_rated?api_key=\(Constant.apiKey)&language=en-US&page=1")
        case .discovery:
            return URL(string: "\(Constant.baseURL)/3/discover/movie?api_key=\(Constant.apiKey)&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1&with_motetization_types=flatrate")
        }
    }
}

enum NetworkError: Error {
    case noData
    case invalidURL
    case decodingError
}

final class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    func getTrendingResult(from url: URL?, completion: @escaping(Result<[Title], NetworkError>) -> Void) {
        guard let url = url else {
            completion(.failure(.invalidURL))
            print("here?")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(.failure(.noData))
                print(error?.localizedDescription ?? "No Error description")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                print("Ошибка статусного кода: \(response.debugDescription)")
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let model = try decoder.decode(TrendingTitleResponse.self, from: data)
                completion(.success(model.results))
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
        
    }
    
    func serch(with query: String, completion: @escaping(Result<[Title], NetworkError>) -> Void) {
        
        guard let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return
        }
        
        let urlString = "\(Constant.baseURL)/3/search/movie?query=\(query)&api_key=\(Constant.apiKey)"
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            print("here?")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                completion(.failure(.noData))
                print(error?.localizedDescription ?? "No Error description")
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let model = try decoder.decode(TrendingTitleResponse.self, from: data)
                completion(.success(model.results))
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
        
    }
    
    func getMovie(with query: String, completion: @escaping(Result<VideoElement, NetworkError>) -> Void) {
        
        guard let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return
        }
        
        let urlString = "\(Constant.baseYoutubeURL)q=\(query)&key=\(Constant.apiKeyYoutube)"
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                completion(.failure(.decodingError))
                print(error?.localizedDescription ?? "No Error description")
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let model = try decoder.decode(YoutubeSearchResponse.self, from: data)
                completion(.success(model.items[0]))
            } catch (let error) {
                completion(.failure(.noData))
                print(error.localizedDescription)
            }
        }.resume()
    }
}

//q=key=[YOUR_API_KEY]

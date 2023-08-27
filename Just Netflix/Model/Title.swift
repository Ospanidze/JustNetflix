//
//  Movie.swift
//  Just Netflix
//
//  Created by Айдар Оспанов on 24.08.2023.
//

import Foundation

struct TrendingTitleResponse: Decodable {
    let results: [Title]
}

struct Title: Decodable {
    let id: Int
    let mediaType: MediaType?
    let originalName: String?
    let originalTitle, overview, posterPath: String?
    let voteAverage: Double
    let voteCount: Int
    let releaseDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case originalName = "original_name"
        case originalTitle = "original_title"
        case overview
        case posterPath = "poster_path"
        case mediaType = "media_type"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case releaseDate = "release_date"
    }
}

enum MediaType: String, Decodable {
    case movie = "movie"
    case tv = "tv"
}

//https://api.themoviedb.org/3/movie/upcoming?api_key=2e347cb6d8489f80bf6bad945941c2a4&language=en-US&page=1

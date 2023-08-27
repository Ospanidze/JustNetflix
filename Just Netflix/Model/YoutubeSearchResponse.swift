//
//  YoutubeSearchResponse.swift
//  Just Netflix
//
//  Created by Айдар Оспанов on 26.08.2023.
//

struct YoutubeSearchResponse: Decodable {
    let items: [VideoElement]
}

struct VideoElement: Decodable {
    let id: VideoType
}

struct VideoType: Decodable {
    let kind: String
    let videoId: String
}

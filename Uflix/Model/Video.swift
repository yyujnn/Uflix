//
//  Video.swift
//  Uflix
//
//  Created by 정유진 on 3/23/25.
//

import Foundation

struct VideoResponse: Codable {
    let results: [Video]
}

struct Video: Codable {
    let key: String?
    let site: String?
    let type: String?
}

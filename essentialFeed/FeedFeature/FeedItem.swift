//
//  FeedItem.swift
//  essentialFeed
//
//  Created by Mathieu Janneau on 27/11/2021.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL?
}

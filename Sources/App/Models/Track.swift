//
//  Track.swift
//  FastStream
//
//  Created by Rostyslav Druzhchenko on 04.11.2019.
//

import FluentSQLite
import Vapor

final class Track: SQLiteModel {

    var id: Int?

    var name: String

    var artist: String

    var duration: Int

    init(id: Int? = nil, name: String, artist: String, duration: Int) {
        self.id = id
        self.name = name
        self.artist = artist
        self.duration = duration
    }
}

extension Track: Migration { }

extension Track: Content { }

extension Track: Parameter { }

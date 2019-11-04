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
}

extension Track: Migration { }

extension Track: Content { }

extension Track: Parameter { }

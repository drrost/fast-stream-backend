//
//  TrackController.swift
//  App
//
//  Created by Rostyslav Druzhchenko on 04.11.2019.
//

import Vapor

final class TrackController {

    func index(_ req: Request) throws -> Future<[Track]> {
        return Track.query(on: req).all()
    }

    func create(_ req: Request) throws -> Future<Track> {
        return try req.content.decode(Track.self).flatMap { track in
            return track.save(on: req)
        }
    }

    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Track.self).flatMap { track in
            return track.delete(on: req)
        }.transform(to: .ok)
    }

}

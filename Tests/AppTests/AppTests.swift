@testable import App
import Vapor
import XCTest

fileprivate let kTrakEndpoint = "http://localhost:8080/track"

final class AppTests: XCTestCase {

    var app: Application!

    override func setUp() {
        do {
            var config = Config.default()
            var env = try Environment.detect()
            var services = Services.default()

            env.commandInput.arguments = []

            try App.configure(&config, &env, &services)

            app = try Application(
                config: config,
                environment: env,
                services: services
            )

            try App.boot(app)
            try app.asyncRun().wait()
        } catch {
            fatalError("Failed to launch Vapor server: \(error.localizedDescription)")
        }

        _ = try? app.client().get("http://localhost:8080/reset").wait()
    }

    override func tearDown() {
        try? app.runningServer?.close().wait()
    }

    func createTrack() -> Track {
        let name = "We are the champions"
        let artist = "The Queen"
        let duration = 256

        return Track(id: nil, name: name, artist: artist, duration: duration)
    }

    func testNothing() throws {
        XCTAssert(true)
    }

    func testNoTracks() throws {
        let response = try app.client().get(kTrakEndpoint).wait()
        let tracks = try response.content.syncDecode([Track].self)
        XCTAssertEqual(tracks.count, 0, "There should be no tracks")
    }

    func testNonexistentTrack() throws {
        let response = try app.client().get("http://localhost:8080/track/556").wait()
        let tracks = try? response.content.syncDecode(Track.self)
        XCTAssertNil(tracks)
    }

    func testCreateTrack() throws {
        _ = try app.client().post(kTrakEndpoint) { postRequest in
            try postRequest.content.encode(createTrack())
        }.wait()

        let response = try app.client().get(kTrakEndpoint).wait()
        let tracks = try response.content.syncDecode([Track].self)
        XCTAssertEqual(tracks.count, 1, "There should be one story")
    }

    func testCreateBadTrack() throws {
        let content = ["content": "This isn't really a track"]

        let response = try app.client().post(kTrakEndpoint) { postRequest in
            try postRequest.content.encode(content)
        }.wait()

        let track = try? response.content.syncDecode(Track.self)
        XCTAssertNil(track, "Creating an invalid track should fail")
    }

    func testUpdateTrack() throws {
        _ = try app.client().post(kTrakEndpoint) { postRequest in
            try postRequest.content.encode(createTrack())
        }.wait()

        let createResponse = try app.client().get(kTrakEndpoint).wait()
        let tracks = try createResponse.content.syncDecode([Track].self)

        if let testTrack = tracks.first {
            testTrack.name = "Modified"

            let updateResponse = try app.client().post(kTrakEndpoint) { postRequest in
                try postRequest.content.encode(testTrack)
            }.wait()

            _ = try updateResponse.content.syncDecode(Track.self)
        } else {
            XCTFail("Unable to fetch the track we created.")
        }
    }

    func testUpdateBadTrack() throws {
        let badTrack = createTrack()
        badTrack.id = 556

        let response = try app.client().post(kTrakEndpoint) { postRequest in
            try postRequest.content.encode(badTrack)
        }.wait()

        _ = try response.content.syncDecode(Track.self)
    }

    static let allTests = [
        ("testNothing", testNothing),
        ("testNoTracks", testNoTracks),
        ("testNonexistentTrack", testNonexistentTrack),
        ("testCreateTrack", testCreateTrack),
        ("testCreateBadTrack", testCreateBadTrack),
        ("testUpdateTrack", testUpdateTrack),
        ("testUpdateBadTrack", testUpdateBadTrack)
    ]
}

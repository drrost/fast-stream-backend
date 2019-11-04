import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    // '/'
    router.get { req in
        return "FastStream based on Swfit/Vapor"
    }

    // MARK: - Track
    let trackController = TrackController()
    let trackMethod = "track"
    router.get(trackMethod, use: trackController.index)
    router.post(trackMethod, use: trackController.create)
    router.delete(trackMethod, Track.parameter, use: trackController.delete)
}

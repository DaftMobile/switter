import Vapor
import HTTP
import Models

final class DeviceMiddleware: Middleware {
	func respond(to request: Request, chainingTo next: Responder) throws -> Response {
		guard let deviceUuid = request.headers["x-device-uuid"]
		else {
			throw Abort(.badRequest, reason: "Could not load device information. Please supply the x-device-uuid header")
		}
		let device = try Device.findOrCreate(uuid: deviceUuid)
		request.storage["device"] = device
		return try next.respond(to: request)
	}
}

extension Request {
	func device() -> Device? {
		return storage["device"] as? Device
	}

	func user() throws -> User? {
		return try device()?.user().get()
	}
}

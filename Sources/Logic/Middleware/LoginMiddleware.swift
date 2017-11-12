import HTTP
import Models

final class LoginMiddleware: Middleware {
	func respond(to request: Request, chainingTo next: Responder) throws -> Response {
		guard let device = request.device() else { throw Abort.serverError }
		if try request.user() == nil {
			let user = User()
			try user.save()
			device.userId = try user.assertExists()
			try device.save()
		}
		guard let user = try request.user() else { throw Abort.serverError }
		return try next.respond(to: request)
	}
}

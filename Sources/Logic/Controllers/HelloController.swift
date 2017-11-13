import Vapor

final class HelloController {
	func hello(request: Request) throws -> ResponseRepresentable {
		return "Hello world!"
	}
}

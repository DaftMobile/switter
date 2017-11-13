import Vapor
import Models

extension Droplet {
	func setupRoutes() throws {
		try self.grouped("api").collection(ApiRoutes(config: config))
    }
}

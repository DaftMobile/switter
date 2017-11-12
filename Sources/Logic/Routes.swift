import Vapor
import Models

extension Droplet {
	func setupRoutes(_ dateSource: DateSourcing = DateSource()) throws {
		let apiRoutes = try ApiRoutes(config: config, dateSource: dateSource)
		try self.grouped("api").collection(apiRoutes)
    }
}

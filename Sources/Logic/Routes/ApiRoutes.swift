import Vapor
import Routing
import HTTP
import Models

/// This class is responsable for authenticating the user and rooting for other controllers
final class ApiRoutes: RouteCollection {

	public typealias Wrapped = Responder

	// MARK: - Middlewares
	private let deviceMiddleware: DeviceMiddleware
	private let loginMiddleware: LoginMiddleware

	var protectedMiddleware: [Middleware] {
		return openMiddleware
	}

	var openMiddleware: [Middleware] {
		return [deviceMiddleware, loginMiddleware]
	}

	// MARK: - Protected controllers

	// MARK: - Open controllers
	private let jokeController: JokeController

	init(config: Config, dateSource: DateSourcing) throws {
		deviceMiddleware = DeviceMiddleware()
		loginMiddleware = LoginMiddleware()

		jokeController = JokeController()
	}

	func build(_ builder: RouteBuilder) throws {
		protectedBuild(builder)
		openBuild(builder)
	}

	private func protectedBuild(_ builder: RouteBuilder) {
//		let protectedRoute = builder.grouped(protectedMiddleware)

		//Register routes here
	}

	private func openBuild(_ builder: RouteBuilder) {
		let openRoute = builder.grouped(openMiddleware)

		openRoute.get("joke", handler: jokeController.joke)

		//Register routes here
//		openRoute.get("leaderboards", handler: leaderboardsController.leaderboards)
//		openRoute.get("score", handler: scoresController.score)
//		openRoute.post("score", handler: scoresController.saveScore)
	}
}

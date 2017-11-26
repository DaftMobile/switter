import Vapor
import Routing
import HTTP
import Models

/// This class is responsable for authenticating the user and rooting for other controllers
final class ApiRoutes: RouteCollection {

	public typealias Wrapped = Responder

	// MARK: - Middlewares
	private let deviceMiddleware = DeviceMiddleware()
	private let loginMiddleware = LoginMiddleware()

	var protectedMiddleware: [Middleware] {
		return [deviceMiddleware, loginMiddleware]
	}

	var openMiddleware: [Middleware] {
		return []
	}

	// MARK: - Protected controllers
	private let jokeController: JokeController
	private let pokemonController: PokemonController

	// MARK: - Open controllers
	private let helloController = HelloController()

	init(config: Config) throws {
		jokeController = try JokeController(config: config)
		pokemonController = try PokemonController(config: config)
	}

	func build(_ builder: RouteBuilder) throws {
		protectedBuild(builder)
		openBuild(builder)
	}

	private func protectedBuild(_ builder: RouteBuilder) {
		let protectedRoute = builder.grouped(protectedMiddleware)

		//Register routes here
		protectedRoute.get("joke", handler: jokeController.joke)
		protectedRoute.get("pokemon", handler: pokemonController.list)
		protectedRoute.get("pokemon", Pokemon.parameter, handler: pokemonController.info)
	}

	private func openBuild(_ builder: RouteBuilder) {
		let openRoute = builder.grouped(openMiddleware)

		//Register routes here
		openRoute.get("hello", handler: helloController.hello)
	}
}

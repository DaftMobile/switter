import Vapor
import Models
import FluentProvider

final class PokemonController {

	private let console: LogProtocol

	init(config: Config) throws {
		console = try config.resolveLog()
	}

	func list(request: Request) throws -> ResponseRepresentable {
		let allPokemon = try Pokemon.all().sorted { $0.0.number < $0.1.number }
		return try allPokemon.makeJSON()
	}

	func info(request: Request) throws -> ResponseRepresentable {
		return try request.parameters.next(Pokemon.self).makeJSON()
	}
}
